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
    public class BaseCRUDService<T, TDb, TSearch, TInsert, TUpdate> : BaseService<T, TDb, TSearch>, ICRUDService<T, TSearch, TInsert, TUpdate> where T : class where TDb : class where TSearch : BaseSearchObject
    {
        public BaseCRUDService(Database.CchV2AliContext dbContext, IMapper mapper) :base(dbContext,mapper)
        {

        }
        public virtual async Task BeforeInsert(TDb tdb, TInsert insert)
        {
        }
        public virtual async Task<T> Insert(TInsert insert)
        {
            var set = _dbContext.Set<TDb>();
            TDb entity = _mapper.Map<TDb>(insert);

            // Postavljanje 'Vidljivo' na true ako postoji takvo svojstvo
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

         //   var entity = set.FindAsync(id);

            _mapper.Map(update, set);

            await _dbContext.SaveChangesAsync();


            return _mapper.Map<T>(set);
        }

        public virtual async Task<T> Delete(int id)
        {
            var set = await _dbContext.Set<TDb>().FindAsync(id);
            if (set == null)
                throw new Exception("ne postoji id");

            try
            {
                // Pokušaj trajnog brisanja
                _dbContext.Set<TDb>().Remove(set);
                await _dbContext.SaveChangesAsync();
            }
            catch (DbUpdateException) // Hvatamo grešku ako trajno brisanje nije moguće
            {
                // Proverava da li objekat ima svojstvo 'Vidljivo'
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
