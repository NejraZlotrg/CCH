using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/poruka")]
    public class PorukaController : BaseCRUDController<CarCareHub.Model.Poruka, PorukaSearchObject, PorukaInsert, PorukaUpdate>
    {


        public PorukaController(ILogger<BaseController<CarCareHub.Model.Poruka, PorukaSearchObject>> logger,
            IPorukaService service) : base(logger, service)
        {

        }

    }
}
