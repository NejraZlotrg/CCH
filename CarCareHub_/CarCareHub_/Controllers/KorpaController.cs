using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using CarCareHub_.Controllers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_
{


    [ApiController]
    [AllowAnonymous]
    [Route("api/korpa")]
    public class KorpaController : BaseCRUDController<Korpa, KorpaSearchObject, KorpaInsert, KorpaUpdate>
    {
        private readonly IKorpaService _korpaService;
        public KorpaController(ILogger<BaseController<Korpa, KorpaSearchObject>> logger,
             IKorpaService korpaService) : base(logger, korpaService)
        {
            _korpaService = korpaService;
        }


        [HttpDelete("deleteProizvodIzKorpe/{korpaId}/{proizvodId}")]
        public async Task<IActionResult> DeleteProizvodIzKorpe(int korpaId, int proizvodId)
        {
            var result = await _korpaService.DeleteProizvodIzKorpe(korpaId, proizvodId);
            if (!result) // Ako metoda vraća false, proizvod nije pronađen ili je došlo do greške
            {
                return NotFound(new { Message = "Proizvod nije pronađen u korpi." });
            }
            return Ok(new { Message = "Proizvod uspešno obrisan iz korpe." });
        }

        [HttpPut("{korpaId}/proizvod/{proizvodId}")]
        public async Task<IActionResult> UpdateKolicina(int? korpaId, int? proizvodId, int novaKolicina)
        {
            try
            {
                await _korpaService.UpdateKolicina(korpaId, proizvodId, novaKolicina);
                return Ok(new { Message = "Količina uspešno ažurirana!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Error = ex.Message });
            }
        }


        [HttpDelete("ocistiKorpu")]
        public async Task<IActionResult> OčistiKorpu(int? klijentId, int? zaposlenikId, int? autoservisId)
        {
           
                await _korpaService.OčistiKorpu(klijentId, zaposlenikId, autoservisId);
                return Ok(new { Message = "Korpa očišćena!" });
           
        }
    }


}

