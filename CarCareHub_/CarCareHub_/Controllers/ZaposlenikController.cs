using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/zaposlenici")]
    [AllowAnonymous]

    public class ZaposleniciController : BaseCRUDController<Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>
    {
        public ZaposleniciController(ILogger<BaseCRUDController<Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>> logger,
            IZaposlenikService zaposlenikService ) : base(logger, zaposlenikService)
        {
        }

        [HttpGet("GetZByGrad")]
        [Authorize(Roles = "Zaposlenik")]

        public async Task<CarCareHub.Model.Zaposlenik> GetByGrad(int id)
        {
            return await (_service as IZaposlenikService).GetByGrad(id);

        }

        [HttpPost("login")]
        [AllowAnonymous]

        public async Task<CarCareHub.Model.Zaposlenik> Login(string username, string password)
        {
            return await (_service as IZaposlenikService).Login(username, password);

        }

    }
}


