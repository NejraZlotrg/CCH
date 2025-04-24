using AutoMapper;
using CarCareHub.Model.SearchObjects;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class BaseService<T, TDb, TSearch> : IService<T, TSearch> where TDb : class where T : class where TSearch : BaseSearchObject
    {
        protected CarCareHub.Services.Database.CchV2AliContext _dbContext;
        protected IMapper _mapper { get; set; }
        public BaseService(Database.CchV2AliContext dbContext, IMapper mapper)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public virtual async Task<PagedResult<T>> GetAdmin(TSearch? search = null)
        {
            var query = _dbContext.Set<TDb>().AsQueryable();
            PagedResult<T> result = new PagedResult<T>();
            query = AddFilter(query, search); 
            query = AddInclude(query, search); 
            result.Count = await query.CountAsync(); 
            
            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value) 
                             .Take(search.PageSize.Value);
            }
            var list = await query.ToListAsync(); 
            result.Result = _mapper.Map<List<T>>(list);
            
            return result;
        }
        public virtual async Task<PagedResult<T>> Get(TSearch? search = null)
        {
            var query = _dbContext.Set<TDb>().AsQueryable();
            var propertyInfo = typeof(TDb).GetProperty("Vidljivo");
            if (propertyInfo != null && propertyInfo.PropertyType == typeof(bool))
            {
                query = query.Where(e => EF.Property<bool>(e, "Vidljivo") == true);
            }
            PagedResult<T> result = new PagedResult<T>();
            query = AddFilter(query, search);
            query = AddInclude(query, search);
            result.Count = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value)
                             .Take(search.PageSize.Value);
            }
            var list = await query.ToListAsync();
            result.Result = _mapper.Map<List<T>>(list);

            return result;
        }
        public virtual IQueryable<TDb> AddInclude(IQueryable<TDb> query, TSearch? search = null)
        {
            return query;
        }
        public virtual IQueryable<TDb> AddFilter(IQueryable<TDb> query, TSearch? search = null)
        {
            return query;
        }
        public virtual async Task<T> GetByID(int id)
        {
            var temp =  await _dbContext.Set<TDb>().FindAsync(id);
            return _mapper.Map<T>(temp);
        }
        public virtual async Task<List<T>> GetByID_(int id)
        {
            var temp = await _dbContext.Set<TDb>().FindAsync(id);
            if (temp != null)
            {
                var propertyInfo = typeof(TDb).GetProperty("Vidljivo");
                if (propertyInfo != null && propertyInfo.PropertyType == typeof(bool))
                {
                    bool isVidljivo = (bool)propertyInfo.GetValue(temp);
                    if (isVidljivo)
                    {
                        return new List<T> { _mapper.Map<T>(temp) };
                    }
                }
            }
            return new List<T>();
        }
    }
}