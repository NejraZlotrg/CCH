using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Authorization;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [AllowAnonymous]
    [Route("api/[controller]")]
    public class UlogeController : BaseCRUDController<Uloge, UlogeSearchObject, UlogeInsert, UlogeUpdate>
    {
        public UlogeController(ILogger<BaseController<CarCareHub.Model.Uloge, UlogeSearchObject>> logger,
             ICRUDService<Uloge, UlogeSearchObject, UlogeInsert, UlogeUpdate> service) : base(logger, service)
        {
        }
    }
}
