using System;
using System.Collections.Generic;

namespace CarCareHub.Services.Database;

public partial class Uloge
{
    public int UlogaId { get; set; }

    public string? NazivUloge { get; set; }

    public virtual ICollection<Autoservi> Autoservis { get; set; } = new List<Autoservi>();

    public virtual ICollection<FirmaAutodijelova> FirmaAutodijelovas { get; set; } = new List<FirmaAutodijelova>();

    public virtual ICollection<Zaposlenik> Zaposleniks { get; set; } = new List<Zaposlenik>();
//public virtual Zaposlenik Zaposlenik { get; set; } 

}
