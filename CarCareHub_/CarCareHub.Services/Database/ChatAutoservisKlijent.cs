using System;

namespace CarCareHub.Services.Database
{
    public class ChatAutoservisKlijent
    {
        public int Id { get; set; }
        public int KlijentId { get; set; }
        public int AutoservisId { get; set; }
        public string Poruka { get; set; }
        public bool PoslanoOdKlijenta { get; set; }  // true = klijent, false = autoservis
        public DateTime VrijemeSlanja { get; set; }

        // Navigaciona svojstva
        public bool Vidljivo { get; set; }
        public virtual Klijent Klijent { get; set; }
        public virtual Autoservis Autoservis { get; set; }
    }
}
