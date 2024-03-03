using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace CarCareHub_.Controllers
{
    [ApiController]
   [Route("api/zaposlenici")]
    public class ZaposleniciController : BaseController<Zaposlenik, ZaposlenikSearchObject>
    {
        protected IZaposlenikService _zaposlenikService;

        public ZaposleniciController(ILogger<BaseController<Zaposlenik, ZaposlenikSearchObject>> logger,
            IZaposlenikService service)
            : base(logger, service)
        {
            _zaposlenikService = service;
        }

        [HttpPost]
        public Zaposlenik Insert(ZaposlenikInsert insert)
        {
            return _zaposlenikService.Insert(insert);
        }
        [HttpPut("{id}")]
        public Zaposlenik Update(int id, ZaposlenikUpdate update)
        {
            return _zaposlenikService.Update(id, update);

        }
    }
}