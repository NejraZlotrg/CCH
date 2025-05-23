﻿using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Text.Json.Serialization;

namespace CarCareHub_.Controllers
{
    [Route("controller")]
    public class BaseController<T, TSearch> : ControllerBase where T : class where TSearch : class
    {
        protected readonly IService<T, TSearch> _service;
        protected readonly ILogger<BaseController<T, TSearch>> _logger;

        public BaseController(ILogger<BaseController<T, TSearch>> logger, IService<T, TSearch> service)
        {
            _logger = logger;
            _service = service;
        }

        [HttpGet()]
        public  async Task<IEnumerable<T>> Get([FromQuery]TSearch search)
        {
            
            return await _service.Get(search);
        }

        

        [HttpGet("{id}")]
        public async Task<T> GetByID(int id)
        {
            return await _service.GetByID(id);
        }
    }
}
