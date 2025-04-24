using CarCareHub.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public interface IService<T, TSearch> where TSearch : class 
   
    {
        Task<PagedResult<T>> Get(TSearch search = null);
        Task<PagedResult<T>> GetAdmin
            (TSearch search = null);
        Task<T> GetByID(int id);
        Task<List<T>> GetByID_(int id);
    }
}
