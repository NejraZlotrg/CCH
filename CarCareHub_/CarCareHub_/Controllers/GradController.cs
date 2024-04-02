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
    public class GradController : BaseCRUDController<Grad, GradSearchObject, GradInsert, GradUpdate>
    {
        public GradController(ILogger<BaseController<CarCareHub.Model.Grad, GradSearchObject>> logger,
             ICRUDService<Grad, GradSearchObject, GradInsert, GradUpdate> service) : base(logger, service)
        {
        }
    }
}
