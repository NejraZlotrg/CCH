using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AutoservisController : BaseCRUDController<CarCareHub.Model.Autoservis, AutoservisSearchObject, AutoservisInsert, AutoservisUpdate>
    {


        public AutoservisController(ILogger<BaseController<CarCareHub.Model.Autoservis, AutoservisSearchObject>> logger,
            IAutoservisService autoservisService) : base(logger, autoservisService)
        {

        }

    }
}
