using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Proizvodjac
{
    public int ProizvodjacId { get; set; }

    public string? NazivProizvodjaca { get; set; }

    public virtual ICollection<Proizvod> Proizvods { get; set; } = new List<Proizvod>();
}
