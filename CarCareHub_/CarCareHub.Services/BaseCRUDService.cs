using AutoMapper;
using CarCareHub.Model.SearchObjects;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;


namespace CarCareHub.Services
{
    public class BaseCRUDService<T, TDb, TSearch, TInsert, TUpdate> : BaseService<T, TDb, TSearch>, ICRUDService<T, TSearch, TInsert, TUpdate> where T : class where TDb : class where TSearch : BaseSearchObject
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        public BaseCRUDService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) :base(dbContext,mapper)
        {
            _httpContextAccessor = httpContextAccessor;
        }
        public virtual async Task BeforeInsert(TDb tdb, TInsert insert)
        {
        }
        public virtual async Task<T> Insert(TInsert insert)
        {
            var set = _dbContext.Set<TDb>();
            TDb entity = _mapper.Map<TDb>(insert);
            var propertyInfo = entity.GetType().GetProperty("Vidljivo");
            propertyInfo.SetValue(entity, true);
            set.Add(entity);
            await BeforeInsert(entity, insert);
            await _dbContext.SaveChangesAsync();

            return _mapper.Map<T>(entity);
        }
        public virtual async Task<T> Update(int id, TUpdate update)
        {
            var set = await _dbContext.Set<TDb>().FindAsync(id);
            _mapper.Map(update, set);
            await _dbContext.SaveChangesAsync();

            return _mapper.Map<T>(set);
        }
        public virtual async Task<T> Delete(int id)
        {
            var user = _httpContextAccessor.HttpContext.User;
            var userRole = user?.FindFirst(ClaimTypes.Role)?.Value;
            var set = await _dbContext.Set<TDb>().FindAsync(id);
            if (set == null)
                throw new Exception("Ne postoji id");
            if (userRole == "Admin")
            {
                try
                {
                    _dbContext.Set<TDb>().Remove(set);
                    await _dbContext.SaveChangesAsync();
                }
                catch (DbUpdateException ex)
                {
                    var propertyInfo = set.GetType().GetProperty("Vidljivo");
                    if (propertyInfo != null && propertyInfo.PropertyType == typeof(bool))
                    {
                        bool vidljivo = (bool)propertyInfo.GetValue(set);
                        if (vidljivo)
                        {
                            propertyInfo.SetValue(set, false);
                            _dbContext.Set<TDb>().Update(set);
                            await _dbContext.SaveChangesAsync();
                        }
                    }
                    else 
                    throw new Exception("Nemoguće obrisati jer postoje povezani podaci.", ex);
                }
            }
            else
            {
                var propertyInfo = set.GetType().GetProperty("Vidljivo");
                if (propertyInfo != null && propertyInfo.PropertyType == typeof(bool))
                {
                    bool vidljivo = (bool)propertyInfo.GetValue(set);
                    if (vidljivo)
                    {
                        propertyInfo.SetValue(set, false);
                        _dbContext.Set<TDb>().Update(set);
                        await _dbContext.SaveChangesAsync();
                    }
                }
            }
            return _mapper.Map<T>(set);
        }
    }
}
