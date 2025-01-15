using CarCareHub.Model;
using CarCareHub.Model.Configurations;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using Stripe;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/placanjeAutoservisDijelovi")]
    public class PlacanjeAutoservisDijeloviController : BaseCRUDController<PlacanjeAutoservisDijelovi, PlacanjeAutoservisDijeloviSearchObject, PlacanjeAutoservisDijeloviInsert, PlacanjeAutoservisDijeloviUpdate>
    {
        private StripeConfig _stripeConfig;

        public PlacanjeAutoservisDijeloviController(ILogger<BaseController<PlacanjeAutoservisDijelovi, PlacanjeAutoservisDijeloviSearchObject>> logger,
             IPlacanjeAutoservisDijeloviService Service,
             IOptionsSnapshot<StripeConfig> stripeConfig) : base(logger, Service)
        {
            _stripeConfig = stripeConfig.Value;
            StripeConfiguration.ApiKey = _stripeConfig.SecretKey;
        }

        [HttpPost("plati")]
        public async Task<IActionResult> CreatePaymentIntent([FromBody] PlacanjeStripe request)
        {
            var service = new PaymentIntentService();

            var options = new PaymentIntentCreateOptions
            {
                Amount = request.Ukupno,
                Currency = "BAM",
            };

            var paymentIntent = await service.CreateAsync(options);

            return Ok(new
            {
                Id = paymentIntent.Id,
                ClientSecret = paymentIntent.ClientSecret
            });
        }
    }
}
