using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Authorization;


namespace CarCareHub_.Controllers
{
    [ApiController]
    //[AllowAnonymous]
    [Route("api/proizvodjac")]
    public class ProizvodjacController : BaseCRUDController<Proizvodjac, ProizvodjacSearchObject, ProizvodjacInsert, ProizvodjacUpdate>
    {
        public ProizvodjacController(ILogger<BaseController<CarCareHub.Model.Proizvodjac, ProizvodjacSearchObject>> logger,
             IProizvodjacService service) : base(logger, service)
        {

        }
    }
}
