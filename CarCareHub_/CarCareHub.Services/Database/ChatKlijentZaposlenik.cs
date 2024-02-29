using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class ChatKlijentZaposlenik
{
    public int ChatKlijentZaposlenikId { get; set; }

    public DateTime? Datum { get; set; }

    public string? Sadrzaj { get; set; }

    public int? ZaposlenikId { get; set; }

    public int? KlijentId { get; set; }

    public virtual Klijent? Klijent { get; set; }

    public virtual Zaposlenik? Zaposlenik { get; set; }
}
