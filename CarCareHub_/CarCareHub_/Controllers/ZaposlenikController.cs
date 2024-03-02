using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace CarCareHub_.Controllers
{
    [ApiController]
   [Route("api/zaposlenici")]
    public class ZaposleniciController : BaseController<Zaposlenik, BaseSearchObject>
    {
        public ZaposleniciController(ILogger<BaseController<Zaposlenik, BaseSearchObject>> logger,
            IService<Zaposlenik, BaseSearchObject> service)
            : base(logger, service)
        {
        }
       
    }
}