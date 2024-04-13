using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Vozilo
{
    public int VoziloId { get; set; }

    public string? MarkaVozila { get; set; }
    public string? ModelVozila { get; set; }

    public int? GodisteVozila { get; set; }

    public string? VrstaVozila { get; set; }

    public virtual ICollection<Autoservis> Autoservis { get; set; } = new List<Autoservis>();
    public virtual ICollection<Proizvod> Proizvods { get; set; } = new List<Proizvod>();

}
