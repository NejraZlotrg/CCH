using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AllowAnonymous]
    public class AutoservisController : BaseCRUDController<CarCareHub.Model.Autoservis, AutoservisSearchObject, AutoservisInsert, AutoservisUpdate>
    {
        public AutoservisController(ILogger<BaseController<CarCareHub.Model.Autoservis, AutoservisSearchObject>> logger,
            IAutoservisService autoservisService) : base(logger, autoservisService)
        {
        }
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<CarCareHub.Model.Autoservis> Login(string username, string password)
        {
            return await (_service as IAutoservisService).Login(username, password);
        }
        [HttpPost("get-id")]
        [AllowAnonymous]
        public IActionResult GetIdByUsernameAndPassword(string username, string password)
        {
            var id = (_service as IAutoservisService)?.GetIdByUsernameAndPassword(username, password);
            if (id == null)
            {
                return NotFound("Invalid username or password");
            }
            return Ok(new { Id = id });
        }
    }
}
