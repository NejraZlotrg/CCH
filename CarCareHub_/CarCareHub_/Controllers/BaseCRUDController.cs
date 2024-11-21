using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using Microsoft.Extensions.Logging;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authorization;
using System.Diagnostics.CodeAnalysis;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/controllerCRUD")]
    //[Authorize]

    public class BaseCRUDController<T, TSearch, TInsert, TUpdate>:  BaseController<T, TSearch> where T : class where TSearch : class
    {
        protected new readonly ICRUDService<T, TSearch, TInsert, TUpdate> _service;
        protected readonly ILogger<BaseController<T, TSearch>> _logger;

        public BaseCRUDController(ILogger<BaseController<T, TSearch>> logger, ICRUDService<T, TSearch, TInsert, TUpdate> service):base(logger,service)
        {
            _logger = logger;
            _service = service;
        }

        /*   [HttpPost("")]
           [AllowAnonymous]
           public virtual async Task<T> Insert([FromBody] TInsert insert)
           {
               return await _service.Insert(insert);
           }*/
        [HttpPost("")]
     //  [AllowAnonymous]
        public virtual async Task<T> Insert([FromBody] TInsert insert)
        {
            //var allowedClasses = new[] { "FirmaAutodijelova", "Autoservis", "Klijent", "Zaposlenik" }; 

            //// Provjera naziva trenutne klase
            //var className = typeof(T).Name;
            //if (!allowedClasses.Contains(className))
            //{
            //    // Vratite grešku za neautorizovane zahtjeve
            //    throw new UnauthorizedAccessException("Access denied.");
            //}

            return await _service.Insert(insert);
        }


        [HttpPut("{id}")]
        public virtual async Task<T> Update(int id, [FromBody] TUpdate update)
        {

            return await _service.Update(id, update);
        }

        [HttpDelete("delete/{id}")]
        public virtual async Task<T> Delete(int id)
        {
            return await _service.Delete(id);
        }
    }
}
