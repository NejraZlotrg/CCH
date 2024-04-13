using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [AllowAnonymous]
    [Route("api/usluge")]
    public class UslugeController : BaseCRUDController<Usluge, UslugeSearchObject, UslugeInsert, UslugeUpdate>
    {
        public UslugeController(ILogger<BaseController<CarCareHub.Model.Usluge, UslugeSearchObject>> logger,
             ICRUDService<Usluge, UslugeSearchObject, UslugeInsert, UslugeUpdate> service) : base(logger, service)
        {
        }
    }
}
