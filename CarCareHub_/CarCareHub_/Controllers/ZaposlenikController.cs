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

        private readonly IZaposlenikService _zaposlenikService;
        public ZaposleniciController(ILogger<BaseCRUDController<Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate>> logger,
            IZaposlenikService zaposlenikService ) : base(logger, zaposlenikService)
        {
            _zaposlenikService = zaposlenikService;
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
            var id = (_service as IZaposlenikService)?.GetIdByUsernameAndPassword(username, password);
            if (id == null)
            {
                return NotFound("Invalid username or password");
            }
            return Ok(new { Id = id });
        }


        [HttpGet("check-username/{username}")]
        [AllowAnonymous]
        public async Task<IActionResult> CheckUsernameExists(string username)
        {
            var exists = await _zaposlenikService.UsernameExists(username);
            return Ok(new { exists });
        }
    }
}
