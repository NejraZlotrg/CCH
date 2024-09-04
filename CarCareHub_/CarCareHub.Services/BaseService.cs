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
        public virtual async Task<PagedResult<T>> Get(TSearch? search = null)
        {
            var query = _dbContext.Set<TDb>().AsQueryable();

            PagedResult<T> result = new PagedResult<T>();



            query = AddFilter(query, search);

            query = AddInclude(query, search);

            result.Count = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Take(search.PageSize.Value).Skip(search.Page.Value * search.PageSize.Value);
            }

            var list = await query.ToListAsync();


            var tmp = _mapper.Map<List<T>>(list);
            result.Result = tmp;
            return result;
        }
        //public virtual async Task<List<T>> Get(TSearch? search=null)
        // {
        //     var query = _dbContext.Set<TDb>().AsQueryable();
        //     query = AddFilter(query, search);
        //     query = AddInclude(query, search);
        //     //query = GetCollection(query, search);
        //   //  query = proizvodCijena(query, search);
        //     //query = IncludeMessages(query, search);

        //     if (search?.Page.HasValue==true && search?.PageSize.HasValue == true)
        //     {
        //         query=query.Take(search.PageSize.Value).Skip(search.Page.Value * search.PageSize.Value);
        //     }

        //     var list = await query.ToListAsync();

        //     return _mapper.Map<List<T>>(list);
        // }
        //public virtual IQueryable<TDb> IncludeMessages(IQueryable<TDb> query, TSearch? search = null)
        //{
        //    return query;
        //}
        //public virtual IQueryable<TDb> IncludeMessages(IQueryable<TDb> query, TSearch? search = null)
        //{

        //    return query;
        //}

        public virtual IQueryable<TDb> AddInclude(IQueryable<TDb> query, TSearch? search = null)
        {
            return query;
        }
        //protected virtual IQueryable<TDb> GetCollection(IQueryable<TDb> query, TSearch? search)
        //{
        //    return query;
        //}


        public virtual IQueryable<TDb> AddFilter(IQueryable<TDb> query, TSearch? search = null)
        {
            return query;
        }

        public virtual async Task<T> GetByID(int id)
        {
            var temp =  await _dbContext.Set<TDb>().FindAsync(id);
            return _mapper.Map<T>(temp);
        }
    }
}
