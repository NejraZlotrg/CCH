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
        {
        }
    }
}
