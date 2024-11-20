using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authorization;
using CarCareHub.Model.SearchObjects;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class BaseController<T, TSearch> : ControllerBase where T : class where TSearch : class
    {
        protected readonly IService<T, TSearch> _service;
        protected readonly ILogger<BaseController<T, TSearch>> _logger;

        public BaseController(ILogger<BaseController<T, TSearch>> logger, IService<T, TSearch> service)
        {
            _logger = logger;
            _service = service;
        }

        [HttpGet]
       // [AllowAnonymous]//----
        public async Task<ActionResult<PagedResult<T>>> Get([FromQuery] TSearch? search = null)
        {
            //----

            //var allowedClasses = new[] { "Grad", "Uloge", "Vozilo" };
            //var className = typeof(T).Name;
            //if (!allowedClasses.Contains(className))
            //{
            //    // Vratite grešku za neautorizovane zahtjeve
            //    throw new UnauthorizedAccessException("Access denied.");
            //}
            //----
            var result = await _service.Get(search);
            return Ok(result); // Ovdje vraćaš 200 OK sa rezultatom
        }





        [HttpGet("[controller]GetByID/{id}")]
        public async Task<T> GetByID(int id)
        {
            return await _service.GetByID(id);
        }

        [HttpGet("{id}")]
        public async Task<List<T>> GetByID_(int id)
        {
            return await _service.GetByID_(id);
        }
    }

}
