using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace CarCareHub_.Controllers
{
    [ApiController]

   [Route("api/zaposlenici")]

    public class ZaposleniciController : BaseCRUDController<Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>
    {

        public ZaposleniciController(ILogger<BaseCRUDController<Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>> logger,
            IZaposlenikService service)
            : base(logger, service)
        {
        }

    }
}