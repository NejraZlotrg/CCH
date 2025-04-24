using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class ChatKlijentZaposlenik
{
    public int ChatKlijentZaposlenikId { get; set; }
    public int KlijentId { get; set; }
    public int ZaposlenikId { get; set; }
    public string Poruka { get; set; }
    public bool PoslanoOdKlijenta { get; set; } 
    public DateTime VrijemeSlanja { get; set; }
    public bool Vidljivo { get; set; }
    public virtual Klijent Klijent { get; set; }
    public virtual Zaposlenik Zaposlenik { get; set; }
}
