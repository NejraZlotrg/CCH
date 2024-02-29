using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class ChatKlijentServi
{
    public int ChatKlijentServisId { get; set; }

    public DateTime? Datum { get; set; }

    public string? Sadrzaj { get; set; }

    public int? AutoservisId { get; set; }

    public int? KlijentId { get; set; }

    public virtual Autoservi? Autoservis { get; set; }

    public virtual Klijent? Klijent { get; set; }
}
