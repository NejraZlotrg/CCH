using CarCareHub.Model;
using CarCareHub.Services;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ChatAutoservisKlijentController : ControllerBase
    {
        private readonly IChatAutoservisKlijentService _chatService;

        public ChatAutoservisKlijentController(IChatAutoservisKlijentService chatService)
        {
            _chatService = chatService;
        }

        [HttpPost("posalji")]
        public async Task<IActionResult> SendMessageAsync(int klijentId, int autoservisId, string poruka, bool poslanoOdKlijenta)
        {
            await _chatService.SendMessageAsync(klijentId, autoservisId, poruka, poslanoOdKlijenta);
            return Ok(new { Message = "Poruka uspješno poslana." });
        }

        [HttpGet("{klijentId}/{autoservisId}")]
        public async Task<IActionResult> GetMessagesAsync(int klijentId, int autoservisId)
        {
            var poruke = await _chatService.GetMessagesAsync(klijentId, autoservisId);
            return Ok(poruke);
        
        }
        
        [HttpGet("byLoggedUser")]
        public IActionResult GetById()
        {
            try
            {
                var chatList = _chatService.GetByID_();
                if (chatList == null || chatList.Count == 0)
                {
                    return NotFound("No chat records found for the logged-in user.");
                }

                return Ok(chatList);
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }



    }
}
