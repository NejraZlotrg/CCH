using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [AllowAnonymous]
    [Route("api/klijent")]
    public class KlijentiController : BaseCRUDController<CarCareHub.Model.Klijent, KlijentSearchObject, KlijentInsert, KlijentUpdate>
    {

        private readonly IKlijentService _klijentService;

        public KlijentiController(ILogger<BaseController<CarCareHub.Model.Klijent, KlijentSearchObject>> logger,
              IKlijentService Service) : base(logger, Service)
        {
            _klijentService = Service;

        }
        [HttpPost("get-id")]
        [AllowAnonymous]
        public IActionResult GetIdByUsernameAndPassword(string username, string password)
        {
            var id = (_service as IKlijentService)?.GetIdByUsernameAndPassword(username, password);
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
            var exists = await _klijentService.UsernameExists(username);
            return Ok(new { exists });
        }

        [HttpPost("get-vidljivo")]
        [AllowAnonymous]
        public IActionResult GetVidljivoByUsernameAndPassword(string username, string password)
        {
            var vidljivo = (_klijentService as IKlijentService)?.GetVidljivoByUsernameAndPassword(username, password);
            if (vidljivo == null)
            {
                return NotFound("Invalid username or password");
            }
            return Ok(new { Vidljivo = vidljivo });
        }
    }
}
