﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public interface IService<T, TSearch> where TSearch : class 
   
    {
        Task<List<T>> Get(TSearch search=null);
        Task<T> GetByID(int id);

    }
}
