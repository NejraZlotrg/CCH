using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using CarCareHub.Services.Database;
using CarCareHub.Model;
using CarCareHub;
using Microsoft.AspNetCore.Authorization;
using CarCareHub.Model.SearchObjects;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/proizvodi")]
    public class ProizvodiController : BaseCRUDController<CarCareHub.Model.Proizvod, CarCareHub.Model.SearchObjects.ProizvodiSearchObject, CarCareHub.Model.ProizvodiInsert, CarCareHub.Model.ProizvodiUpdate>
    {
        private readonly IRecommenderService _recommenderService;
        public ProizvodiController(ILogger<BaseController<CarCareHub.Model.Proizvod, CarCareHub.Model.SearchObjects.ProizvodiSearchObject>> logger, 
            IProizvodiService service,
            IRecommenderService recommenderService) : base(logger, service)
        {
            _recommenderService = recommenderService;
        }

        [AllowAnonymous]
        [HttpGet("[controller]GetAllAnonymous")]
        public async Task<PagedResult<CarCareHub.Model.Proizvod>> Get([FromQuery] CarCareHub.Model.SearchObjects.ProizvodiSearchObject search)
        {

            return await _service.Get(search);
        }
    

        [HttpPut("{id}/activate")]

        public virtual async Task<CarCareHub.Model.Proizvod> Activate(int id)
        {

            return await (_service as IProizvodiService).Activate(id);
        }

        [HttpPut("{id}/hide")]
        public virtual async Task<CarCareHub.Model.Proizvod> Hide(int id)
        {

            return await (_service as IProizvodiService).Hide(id);
        }
        [HttpGet("allowedActions")]
        public virtual async Task<List<string>> AllowedActions (int id)
        {

            return await (_service as IProizvodiService).AllowedActions(id);
        }

        [AllowAnonymous]
        [HttpGet("GetForUsers")]
        public async Task<ActionResult<PagedResult<CarCareHub.Model.Proizvod>>> GetForUsers([FromQuery] ProizvodiSearchObject search = null)
        {
            var result = await (_service as IProizvodiService)?.GetForUsers(search);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [AllowAnonymous]
        [HttpGet("GetByFirmaAutodijelovaID/{firmaautodijelovaid}")]
        public async Task<ActionResult<PagedResult<CarCareHub.Model.Proizvod>>> GetByFirmaAutodijelovaID(int firmaautodijelovaid)
        {
            var result = await (_service as IProizvodiService)?.GetByFirmaAutodijelovaID(firmaautodijelovaid);

            if (result == null || result.Result.Count == 0)
                return NotFound("Nema proizvoda za ovu firmu autodijelova.");

            return Ok(result);
        }

        [HttpGet("recommend/{proizvodId}")]
        public async Task<IActionResult> Recommend(long proizvodId, CancellationToken cancellationToken)
        {
            var result = await _recommenderService.GetRecommendationsByArticleId(proizvodId, cancellationToken);

            return Ok(result);
        }

    }
}
