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

        [HttpPost("get-id")]
        [AllowAnonymous]
        public IActionResult GetIdByUsernameAndPassword(string username, string password)
        {
            // Poziv metode servisa za dobivanje korisničkog ID-a.
            var id = (_service as IZaposlenikService)?.GetIdByUsernameAndPassword(username, password);

            // Ako korisnik nije pronađen, vraća 404 status sa porukom.
            if (id == null)
            {
                return NotFound("Invalid username or password");
            }

            // Ako je korisnik pronađen, vraća ID u formatu JSON.
            return Ok(new { Id = id });
        }

    }
}


