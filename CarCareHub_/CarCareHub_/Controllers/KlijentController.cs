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
        public KlijentiController(ILogger<BaseController<CarCareHub.Model.Klijent, KlijentSearchObject>> logger,
              IKlijentService Service) : base(logger, Service)
        {
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
    }
}