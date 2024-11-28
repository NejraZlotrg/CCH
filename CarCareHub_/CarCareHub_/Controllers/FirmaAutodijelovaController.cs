using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using CarCareHub.Services.Database;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using Microsoft.AspNetCore.Authorization;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/firmaAutodijelova")]
    [AllowAnonymous]

    public class FirmaAutodijelovaController : BaseCRUDController<CarCareHub.Model.FirmaAutodijelova, FirmaAutodijelovaSearchObject, FirmaAutodijelovaInsert, FirmaAutodijelovaUpdate>
    {


        public FirmaAutodijelovaController(ILogger<BaseController<CarCareHub.Model.FirmaAutodijelova, FirmaAutodijelovaSearchObject>> logger,
            IFirmaAutodijelovaService firmaAutodijelovaService) : base(logger, firmaAutodijelovaService)
        {
           
        }


        [HttpPost("login")]
        [AllowAnonymous]

        public async Task<CarCareHub.Model.FirmaAutodijelova> Login(string username, string password)
        {
            return await (_service as IFirmaAutodijelovaService).Login(username, password);

        }

    }
}
