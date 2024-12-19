using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ChatController : ControllerBase
    {
        private readonly ChatService _chatService;

        public ChatController(ChatService chatService)
        {
            _chatService = chatService;
        }

        [HttpPost("posalji")]
        public async Task<IActionResult> PosaljiPoruku(int klijentId, int autoservisId, string poruka, bool poslanoOdKlijenta)
        {
            await _chatService.SnimiPorukuAsync(klijentId, autoservisId, poruka, poslanoOdKlijenta);
            return Ok("Poruka poslana.");
        }
    }
}
