using AutoMapper;
using CarCareHub.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class BaseCRUDService<T, TDb, TSearch, TInsert, TUpdate> : BaseService<T, TDb, TSearch> where T : class where TDb : class where TSearch : BaseSearchObject
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

            TDb entity=_mapper.Map<TDb>(insert);

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
    }
}
