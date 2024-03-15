using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/zaposlenici")]
    public class ZaposleniciController : BaseCRUDController<Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>
    {
        public ZaposleniciController(ILogger<BaseCRUDController<Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>> logger,
            ICRUDService<Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate> service)
            : base(logger, service)
        {
        }
    }
}

