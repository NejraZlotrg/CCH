using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using CarCareHub.Services.Database;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/firmaAutodijelova")]
    public class FirmaAutodijelovaController : BaseCRUDController<CarCareHub.Model.FirmaAutodijelova, FirmaAutodijelovaSearchObject, FirmaAutodijelovaInsert, FirmaAutodijelovaUpdate>
    {


        public FirmaAutodijelovaController(ILogger<BaseController<CarCareHub.Model.FirmaAutodijelova, FirmaAutodijelovaSearchObject>> logger,
            IFirmaAutodijelovaService firmaAutodijelovaService) : base(logger, firmaAutodijelovaService)
        {
           
        }
     
    }
}
