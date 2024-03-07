using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using CarCareHub.Services.Database;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/proizvodi")]
    public class ProizvodiController : BaseCRUDController<CarCareHub.Model.Proizvod, ProizvodiSearchObject, ProizvodiInsert, ProizvodiUpdate>
    {

        public ProizvodiController(ILogger<BaseCRUDController<CarCareHub.Model.Proizvod, ProizvodiSearchObject, ProizvodiInsert, ProizvodiUpdate>> logger,
            IProizvodiService service)
            : base(logger, service)
        {
        }


    }
}
