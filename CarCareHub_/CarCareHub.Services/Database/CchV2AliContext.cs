using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace CarCareHub.Services.Database;

public partial class CchV2AliContext : DbContext
{
    public CchV2AliContext()
    {
    }

    public CchV2AliContext(DbContextOptions<CchV2AliContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Autoservi> Autoservis { get; set; }

    public virtual DbSet<ChatKlijentServi> ChatKlijentServis { get; set; }

    public virtual DbSet<ChatKlijentZaposlenik> ChatKlijentZaposleniks { get; set; }

    public virtual DbSet<Drzava> Drzavas { get; set; }

    public virtual DbSet<FirmaAutodijelova> FirmaAutodijelovas { get; set; }

    public virtual DbSet<Grad> Grads { get; set; }

    public virtual DbSet<Izvjestaj> Izvjestajs { get; set; }

    public virtual DbSet<Kategorija> Kategorijas { get; set; }

    public virtual DbSet<Klijent> Klijents { get; set; }

    public virtual DbSet<Narudzba> Narudzbas { get; set; }

    public virtual DbSet<NarudzbaStavka> NarudzbaStavkas { get; set; }

    public virtual DbSet<PlacanjeAutoservisDijelovi> PlacanjeAutoservisDijelovis { get; set; }

    public virtual DbSet<Popust> Popusts { get; set; }

    public virtual DbSet<Proizvod> Proizvods { get; set; }

    public virtual DbSet<Proizvodjac> Proizvodjacs { get; set; }

    public virtual DbSet<Uloge> Uloges { get; set; }

    public virtual DbSet<Usluge> Usluges { get; set; }

    public virtual DbSet<Vozilo> Vozilos { get; set; }

    public virtual DbSet<Zaposlenik> Zaposleniks { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer(" Integrated Security=SSPI;Initial Catalog=CCH_v2_Ali;Data Source=localhost; TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Autoservi>(entity =>
        {
            entity.HasKey(e => e.AutoservisId).HasName("PK_autoservis");

            entity.Property(e => e.AutoservisId).HasColumnName("AutoservisID");
            entity.Property(e => e.Adresa)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("adresa");
            entity.Property(e => e.Email)
                .HasMaxLength(30)
                .IsUnicode(false)
                .HasColumnName("email");
            entity.Property(e => e.GradId).HasColumnName("gradID");
            entity.Property(e => e.Jib)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("jib");
            entity.Property(e => e.Mbs)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("MBS");
            entity.Property(e => e.Naziv)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("naziv");
            entity.Property(e => e.Password)
                .HasMaxLength(30)
                .IsUnicode(false)
                .HasColumnName("password_");
            entity.Property(e => e.SlikaProfila)
                .HasMaxLength(40)
                .IsUnicode(false)
                .HasColumnName("slika_Profila");
            entity.Property(e => e.Telefon)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("telefon");
            entity.Property(e => e.UlogaId).HasColumnName("ulogaID");
            entity.Property(e => e.UslugeId).HasColumnName("uslugeID");
            entity.Property(e => e.VoziloId).HasColumnName("voziloID");

            entity.HasOne(d => d.Grad).WithMany(p => p.Autoservis)
                .HasForeignKey(d => d.GradId)
                .HasConstraintName("fk_autoservis_grad");

            entity.HasOne(d => d.Uloga).WithMany(p => p.Autoservis)
                .HasForeignKey(d => d.UlogaId)
                .HasConstraintName("fk_uloga_autoservis");

            entity.HasOne(d => d.Usluge).WithMany(p => p.Autoservis)
                .HasForeignKey(d => d.UslugeId)
                .HasConstraintName("fk_u_a");

            entity.HasOne(d => d.Vozilo).WithMany(p => p.Autoservis)
                .HasForeignKey(d => d.VoziloId)
                .HasConstraintName("fk_v_a");
        });

        modelBuilder.Entity<ChatKlijentServi>(entity =>
        {
            entity.HasKey(e => e.ChatKlijentServisId).HasName("pk_chat");

            entity.ToTable("Chat_klijent_servis");

            entity.Property(e => e.ChatKlijentServisId).HasColumnName("ChatKlijentServisID");
            entity.Property(e => e.AutoservisId).HasColumnName("autoservis_id");
            entity.Property(e => e.Datum)
                .HasColumnType("datetime")
                .HasColumnName("datum");
            entity.Property(e => e.KlijentId).HasColumnName("klijent_id");
            entity.Property(e => e.Sadrzaj)
                .HasColumnType("text")
                .HasColumnName("sadrzaj");

            entity.HasOne(d => d.Autoservis).WithMany(p => p.ChatKlijentServis)
                .HasForeignKey(d => d.AutoservisId)
                .HasConstraintName("fk_autoservis_chat");

            entity.HasOne(d => d.Klijent).WithMany(p => p.ChatKlijentServis)
                .HasForeignKey(d => d.KlijentId)
                .HasConstraintName("fk_klijent_chat");
        });

        modelBuilder.Entity<ChatKlijentZaposlenik>(entity =>
        {
            entity.HasKey(e => e.ChatKlijentZaposlenikId).HasName("pk_chat2");

            entity.ToTable("Chat_klijent_zaposlenik");

            entity.Property(e => e.ChatKlijentZaposlenikId).HasColumnName("ChatKlijentZaposlenikID");
            entity.Property(e => e.Datum)
                .HasColumnType("datetime")
                .HasColumnName("datum");
            entity.Property(e => e.KlijentId).HasColumnName("klijent_id");
            entity.Property(e => e.Sadrzaj)
                .HasColumnType("text")
                .HasColumnName("sadrzaj");
            entity.Property(e => e.ZaposlenikId).HasColumnName("zaposlenik_id");

            entity.HasOne(d => d.Klijent).WithMany(p => p.ChatKlijentZaposleniks)
                .HasForeignKey(d => d.KlijentId)
                .HasConstraintName("fk_klijent_chat2");

            entity.HasOne(d => d.Zaposlenik).WithMany(p => p.ChatKlijentZaposleniks)
                .HasForeignKey(d => d.ZaposlenikId)
                .HasConstraintName("fk_zaposlenik_chat2");
        });

        modelBuilder.Entity<Drzava>(entity =>
        {
            entity.HasKey(e => e.DrzavaId).HasName("PK_drzava");

            entity.ToTable("Drzava");

            entity.Property(e => e.DrzavaId).HasColumnName("DrzavaID");
            entity.Property(e => e.NazivDrzave)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("naziv_drzave");
        });

        modelBuilder.Entity<FirmaAutodijelova>(entity =>
        {
            entity.HasKey(e => e.FirmaId).HasName("PK_firma");

            entity.ToTable("Firma_autodijelova");

            entity.Property(e => e.FirmaId).HasColumnName("FirmaID");
            entity.Property(e => e.Adresa)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("adresa");
            entity.Property(e => e.Email)
                .HasMaxLength(30)
                .IsUnicode(false)
                .HasColumnName("email");
            entity.Property(e => e.GradId).HasColumnName("gradID");
            entity.Property(e => e.IzvjestajId).HasColumnName("izvjestajID");
            entity.Property(e => e.NazivFirme)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("naziv_firme");
            entity.Property(e => e.Password)
                .HasMaxLength(30)
                .IsUnicode(false)
                .HasColumnName("password_");
            entity.Property(e => e.SlikaProfila)
                .HasMaxLength(40)
                .IsUnicode(false)
                .HasColumnName("slika_Profila");
            entity.Property(e => e.Telefon)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("telefon");
            entity.Property(e => e.UlogaId).HasColumnName("ulogaID");

            entity.HasOne(d => d.Grad).WithMany(p => p.FirmaAutodijelovas)
                .HasForeignKey(d => d.GradId)
                .HasConstraintName("fk_autoservis_grads");

            entity.HasOne(d => d.Izvjestaj).WithMany(p => p.FirmaAutodijelovas)
                .HasForeignKey(d => d.IzvjestajId)
                .HasConstraintName("fk_i_fad");

            entity.HasOne(d => d.Uloga).WithMany(p => p.FirmaAutodijelovas)
                .HasForeignKey(d => d.UlogaId)
                .HasConstraintName("fk_uloga_firmaautodijelova");

            entity.HasMany(d => d.Proizvods).WithMany(p => p.Firmas)
                .UsingEntity<Dictionary<string, object>>(
                    "FirmaAutodijelovaProizvod",
                    r => r.HasOne<Proizvod>().WithMany()
                        .HasForeignKey("ProizvodId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__FirmaAuto__proiz__00200768"),
                    l => l.HasOne<FirmaAutodijelova>().WithMany()
                        .HasForeignKey("FirmaId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__FirmaAuto__firma__7F2BE32F"),
                    j =>
                    {
                        j.HasKey("FirmaId", "ProizvodId").HasName("PK__FirmaAut__4F1EF5F45990B64A");
                        j.ToTable("FirmaAutodijelova_Proizvod");
                        j.IndexerProperty<int>("FirmaId").HasColumnName("firmaID");
                        j.IndexerProperty<int>("ProizvodId").HasColumnName("proizvodID");
                    });
        });

        modelBuilder.Entity<Grad>(entity =>
        {
            entity.HasKey(e => e.GradId).HasName("PK_grad");

            entity.ToTable("Grad");

            entity.Property(e => e.GradId).HasColumnName("GradID");
            entity.Property(e => e.DrzavaId).HasColumnName("drzavaID");
            entity.Property(e => e.NazivGrada)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("naziv_grada");

            entity.HasOne(d => d.Drzava).WithMany(p => p.Grads)
                .HasForeignKey(d => d.DrzavaId)
                .HasConstraintName("fk_d_g");
        });

        modelBuilder.Entity<Izvjestaj>(entity =>
        {
            entity.HasKey(e => e.IzvjestajId).HasName("PK_izvjestaj");

            entity.ToTable("Izvjestaj");

            entity.Property(e => e.IzvjestajId).HasColumnName("IzvjestajID");
        });

        modelBuilder.Entity<Kategorija>(entity =>
        {
            entity.HasKey(e => e.KategorijaId).HasName("PK_kategorija");

            entity.ToTable("Kategorija");

            entity.Property(e => e.KategorijaId).HasColumnName("KategorijaID");
            entity.Property(e => e.NazivKategorije)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("naziv_kategorije");
        });

        modelBuilder.Entity<Klijent>(entity =>
        {
            entity.HasKey(e => e.KlijentId).HasName("PK_klijent");

            entity.ToTable("Klijent");

            entity.Property(e => e.KlijentId).HasColumnName("KlijentID");
            entity.Property(e => e.BrojTelefona)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("broj_telefona");
            entity.Property(e => e.Email)
                .HasMaxLength(30)
                .IsUnicode(false)
                .HasColumnName("email");
            entity.Property(e => e.GradId).HasColumnName("gradID");
            entity.Property(e => e.Ime)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("ime");
            entity.Property(e => e.Password)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("password_");
            entity.Property(e => e.Prezime)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("prezime");
            entity.Property(e => e.Spol)
                .HasMaxLength(10)
                .IsUnicode(false)
                .HasColumnName("spol");
            entity.Property(e => e.Username)
                .HasMaxLength(30)
                .IsUnicode(false)
                .HasColumnName("username");

            entity.HasOne(d => d.Grad).WithMany(p => p.Klijents)
                .HasForeignKey(d => d.GradId)
                .HasConstraintName("fk_klijent_grad");
        });

        modelBuilder.Entity<Narudzba>(entity =>
        {
            entity.HasKey(e => e.NarudzbaId).HasName("pk_n");

            entity.ToTable("Narudzba");

            entity.Property(e => e.NarudzbaId).HasColumnName("NarudzbaID");
            entity.Property(e => e.DatumIsporuke)
                .HasColumnType("date")
                .HasColumnName("datum_isporuke");
            entity.Property(e => e.DatumNarudzbe)
                .HasColumnType("date")
                .HasColumnName("datum_narudzbe");
            entity.Property(e => e.NarudzbaStavkeId).HasColumnName("narudzbaStavkeID");
            entity.Property(e => e.PopustId).HasColumnName("popustID");
            entity.Property(e => e.ZavrsenaNarudzba).HasColumnName("zavrsena_narudzba");

            entity.HasOne(d => d.NarudzbaStavke).WithMany(p => p.Narudzbas)
                .HasForeignKey(d => d.NarudzbaStavkeId)
                .HasConstraintName("fk_ns_n");

            entity.HasOne(d => d.Popust).WithMany(p => p.Narudzbas)
                .HasForeignKey(d => d.PopustId)
                .HasConstraintName("fk_n_p");
        });

        modelBuilder.Entity<NarudzbaStavka>(entity =>
        {
            entity.HasKey(e => e.NarudzbaStavkaId).HasName("pk_ns");

            entity.ToTable("Narudzba_Stavka");

            entity.Property(e => e.NarudzbaStavkaId).HasColumnName("Narudzba_stavkaID");
            entity.Property(e => e.Cijena)
                .HasColumnType("decimal(8, 2)")
                .HasColumnName("cijena");
            entity.Property(e => e.Kolicina).HasColumnName("kolicina");
            entity.Property(e => e.ProizvodId).HasColumnName("proizvodID");

            entity.HasOne(d => d.Proizvod).WithMany(p => p.NarudzbaStavkas)
                .HasForeignKey(d => d.ProizvodId)
                .HasConstraintName("fk_ns_p");
        });

        modelBuilder.Entity<PlacanjeAutoservisDijelovi>(entity =>
        {
            entity.HasKey(e => e.PlacanjeId).HasName("pk_pl");

            entity.ToTable("placanje_autoservis_dijelovi");

            entity.Property(e => e.PlacanjeId).HasColumnName("PlacanjeID");
            entity.Property(e => e.Datum)
                .HasColumnType("datetime")
                .HasColumnName("datum");
            entity.Property(e => e.Iznos).HasColumnName("iznos");
            entity.Property(e => e.Posiljaoc).HasColumnName("posiljaoc");
            entity.Property(e => e.Primalac).HasColumnName("primalac");

            entity.HasOne(d => d.PosiljaocNavigation).WithMany(p => p.PlacanjeAutoservisDijelovis)
                .HasForeignKey(d => d.Posiljaoc)
                .HasConstraintName("fk_plad");

            entity.HasOne(d => d.PrimalacNavigation).WithMany(p => p.PlacanjeAutoservisDijelovis)
                .HasForeignKey(d => d.Primalac)
                .HasConstraintName("fk_primad");
        });

        modelBuilder.Entity<Popust>(entity =>
        {
            entity.HasKey(e => e.PopustId).HasName("pk_popust");

            entity.ToTable("Popust");

            entity.Property(e => e.PopustId).HasColumnName("PopustID");
            entity.Property(e => e.AutoservisId).HasColumnName("autoservis_id");
            entity.Property(e => e.FirmaAutodijelovaId).HasColumnName("firma_autodijelovaID");
            entity.Property(e => e.VrijednostPopusta).HasColumnName("vrijednost_popusta");

            entity.HasOne(d => d.Autoservis).WithMany(p => p.Popusts)
                .HasForeignKey(d => d.AutoservisId)
                .HasConstraintName("fk_autoservis_popust");

            entity.HasOne(d => d.FirmaAutodijelova).WithMany(p => p.Popusts)
                .HasForeignKey(d => d.FirmaAutodijelovaId)
                .HasConstraintName("fk_firma_Popust");
        });

        modelBuilder.Entity<Proizvod>(entity =>
        {
            entity.HasKey(e => e.ProizvodId).HasName("pk_proizvod");

            entity.ToTable("Proizvod");

            entity.Property(e => e.ProizvodId).HasColumnName("ProizvodID");
            entity.Property(e => e.Cijena)
                .HasColumnType("money")
                .HasColumnName("cijena");
            entity.Property(e => e.KategorijaId).HasColumnName("kategorijaID");
            entity.Property(e => e.Model)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("model");
            entity.Property(e => e.Naziv)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("naziv");
            entity.Property(e => e.Opis)
                .HasColumnType("text")
                .HasColumnName("opis");
            entity.Property(e => e.OriginalniBroj)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("originalni_broj");
            entity.Property(e => e.ProizvodjacId).HasColumnName("proizvodjacID");
            entity.Property(e => e.Sifra)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("sifra");

            entity.HasOne(d => d.Kategorija).WithMany(p => p.Proizvods)
                .HasForeignKey(d => d.KategorijaId)
                .HasConstraintName("fk_kategorija_proizvod");

            entity.HasOne(d => d.Proizvodjac).WithMany(p => p.Proizvods)
                .HasForeignKey(d => d.ProizvodjacId)
                .HasConstraintName("fk_proizvodjac_proizvod");
        });

        modelBuilder.Entity<Proizvodjac>(entity =>
        {
            entity.HasKey(e => e.ProizvodjacId).HasName("PK_proizvodjac");

            entity.ToTable("Proizvodjac");

            entity.Property(e => e.ProizvodjacId).HasColumnName("ProizvodjacID");
            entity.Property(e => e.NazivProizvodjaca)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("naziv_proizvodjaca");
        });

        modelBuilder.Entity<Uloge>(entity =>
        {
            entity.HasKey(e => e.UlogaId).HasName("PK_uloga");

            entity.ToTable("Uloge");

            entity.Property(e => e.UlogaId).HasColumnName("UlogaID");
            entity.Property(e => e.NazivUloge)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("naziv_uloge");
        });

        modelBuilder.Entity<Usluge>(entity =>
        {
            entity.HasKey(e => e.UslugeId).HasName("PK_usluge");

            entity.ToTable("Usluge");

            entity.Property(e => e.UslugeId).HasColumnName("UslugeID");
            entity.Property(e => e.Cijena)
                .HasColumnType("decimal(8, 2)")
                .HasColumnName("cijena");
            entity.Property(e => e.NazivUsluge)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("naziv_usluge");
            entity.Property(e => e.Opis)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("opis");
        });

        modelBuilder.Entity<Vozilo>(entity =>
        {
            entity.HasKey(e => e.VoziloId).HasName("PK_vozilo");

            entity.ToTable("Vozilo");

            entity.Property(e => e.VoziloId).HasColumnName("VoziloID");
            entity.Property(e => e.GodisteVozila)
                .HasMaxLength(4)
                .IsUnicode(false)
                .HasColumnName("godiste_vozila");
            entity.Property(e => e.MarkaVozila)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("marka_vozila");
            entity.Property(e => e.VrstaVozila)
                .HasMaxLength(30)
                .IsUnicode(false)
                .HasColumnName("vrsta_vozila");
        });

        modelBuilder.Entity<Zaposlenik>(entity =>
        {
            entity.HasKey(e => e.ZaposlenikId).HasName("PK_zaposlenik");

            entity.ToTable("Zaposlenik");

            entity.Property(e => e.ZaposlenikId).HasColumnName("ZaposlenikID");
            entity.Property(e => e.AutoservisId).HasColumnName("autoservisID");
            entity.Property(e => e.DatumRodjenja)
                .HasColumnType("date")
                .HasColumnName("datum_rodjenja");
            entity.Property(e => e.Email)
                .HasMaxLength(30)
                .IsUnicode(false)
                .HasColumnName("email");
            entity.Property(e => e.FirmaAutodijelovaId).HasColumnName("firma_autodijelovaID");
            entity.Property(e => e.Ime)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("ime");
            entity.Property(e => e.Password)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("password_");
            entity.Property(e => e.Prezime)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("prezime");
            entity.Property(e => e.UlogaId).HasColumnName("ulogaID");
            entity.Property(e => e.Username)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasColumnName("username");

            entity.HasOne(d => d.Autoservis).WithMany(p => p.Zaposleniks)
                .HasForeignKey(d => d.AutoservisId)
                .HasConstraintName("fk_zaposlenik_autoservis");

            entity.HasOne(d => d.FirmaAutodijelova).WithMany(p => p.Zaposleniks)
                .HasForeignKey(d => d.FirmaAutodijelovaId)
                .HasConstraintName("fk_firma_zaposlenik");

            entity.HasOne(d => d.Uloga).WithMany(p => p.Zaposleniks)
                .HasForeignKey(d => d.UlogaId)
                .HasConstraintName("fk_uloga_zaposlenik");

            entity.HasMany(d => d.Proizvods).WithMany(p => p.Zaposleniks)
                .UsingEntity<Dictionary<string, object>>(
                    "ZaposlenikProizvod",
                    r => r.HasOne<Proizvod>().WithMany()
                        .HasForeignKey("ProizvodId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__Zaposleni__proiz__7C4F7684"),
                    l => l.HasOne<Zaposlenik>().WithMany()
                        .HasForeignKey("ZaposlenikId")
                        .OnDelete(DeleteBehavior.ClientSetNull)
                        .HasConstraintName("FK__Zaposleni__zapos__7B5B524B"),
                    j =>
                    {
                        j.HasKey("ZaposlenikId", "ProizvodId").HasName("PK__Zaposlen__50FD668EDF7047CD");
                        j.ToTable("Zaposlenik_Proizvod");
                        j.IndexerProperty<int>("ZaposlenikId").HasColumnName("zaposlenikID");
                        j.IndexerProperty<int>("ProizvodId").HasColumnName("proizvodID");
                    });
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
