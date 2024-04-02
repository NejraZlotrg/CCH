using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using CarCareHub.Services.Database;
using CarCareHub.Model;
using CarCareHub;
namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("[Controller]")]
    public class ProizvodiController : BaseCRUDController<CarCareHub.Model.Proizvod, CarCareHub.Model.SearchObjects.ProizvodiSearchObject, CarCareHub.Model.ProizvodiInsert, CarCareHub.Model.ProizvodiUpdate>
    {
        public ProizvodiController(ILogger<BaseController<CarCareHub.Model.Proizvod, CarCareHub.Model.SearchObjects.ProizvodiSearchObject>> logger, 
            IProizvodiService service) : base(logger, service)
        { }


        [HttpPut("{id}/activate")]
        public virtual async Task<CarCareHub.Model.Proizvod> Activate(int id)
        {

            return await (_service as IProizvodiService).Activate(id);
        }

        [HttpPut("{id}/hide")]
        public virtual async Task<CarCareHub.Model.Proizvod> Hide(int id)
        {

            return await (_service as IProizvodiService).Hide(id);
        }

        [HttpGet("allowedActions")]
        public virtual async Task<List<string>> AllowedActions (int id)
        {

            return await (_service as IProizvodiService).AllowedActions(id);
        }
    }
}
