-- Estado de Cuenta Trimestral de Factultativos

-- Creado    : 17/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 17/02/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_prod_sp_pro88_dw1 - DEIVID, S.A.

--drop procedure sp_pro88m;

create procedure sp_pr88m(
a_compania	char(3),
a_ano	    smallint,
a_trimestre	smallint)
RETURNING nombre_coasegur,     -- Reasegurador
	      nombre_ramo,	       -- Ramo
		  participacion,       -- Porcentaje de participacion
		  trimestre,	       -- trimestre
		  ano,			       -- ano
		  prima_haber,	       -- prima_haber
		  prima_debe,          -- prima_debe
		  comision_debe,       -- comision_debe
		  comision_haber,      -- comision_haber
		  impuestos_debe,      -- impuesto_debe
		  impuesto_haber,      -- impuesto_haber
		  siniestro_pag_debe,  -- siniestro_pag_debe
		  siniestro_pag_haber, -- siniestro_pag_haber
	 	  compania_nombre;     -- compania

define ls_ano			   char(4);
define ls_periodo1		   char(7);
define ls_periodo2		   char(7);
define ls_cod_rease 	   char(3);
define ls_no_poliza		   char(10);
define ls_no_endoso		   char(5);
define ls_cod_ramo	       char(20);
define ls_nombre_ramo	   char(20);
define ls_nombre_coasegur  char(20);
define ls_no_reclamo       char(10);

define ld_monto            dec(16,2);
define ld_prima			   dec(16,2);
define ld_comision         dec(16,2);
define ld_impuesto         dec(16,2);
define ld_porc_comision	   dec(16,2);
define ld_porc_impuesto	   dec(16,2);
define ld_porc_partic_reas dec(16,2);
define ld_prima_bruta      dec(16,2);

create temp table tmp_estcufa(
	cod_reasegurador	char(3),
	ano					smallint,
	trimestre			smallint,
	primas				dec(16,2) default 0.00,
	reserva_devuelta	dec(16,2) default 0.00,
	int_reserva_dev		dec(16,2) default 0.00,
	imp_int_res_dev		dec(16,2) default 0.00,
	comision			dec(16,2) default 0.00,
	impuestos			dec(16,2) default 0.00,
	sobrecomision		dec(16,2) default 0.00,
	siniestro_pagado	dec(16,2) default 0.00,
	siniestro_contado	dec(16,2) default 0.00,
	reserva_retenida	dec(16,2) default 0.00,
	saldo_reases		dec(16,2) default 0.00
) with no log;

let ls_ano = a_ano;

if   a_trimestre = 1 then
	let ls_periodo1 = ls_ano || "-01";
	let ls_periodo2 = ls_ano || "-03";
elif a_trimestre = 2 then
	let ls_periodo1 = ls_ano || "-04";
	let ls_periodo2 = ls_ano || "-06";
elif a_trimestre = 3 then
	let ls_periodo1 = ls_ano || "-07";
	let ls_periodo2 = ls_ano || "-09";
else 
	let ls_periodo1 = ls_ano || "-10";
	let ls_periodo2 = ls_ano || "-12";
end if

delete from reaestfa
 where trimestre = a_trimestre
   and ano       = a_ano;

-- Primas Suscritas, Comision, Impuestos

foreach
 select	no_poliza,
        no_endoso
  into	ls_no_poliza,
        ls_no_endoso
   from endedmae
  where cod_compania = a_compania
	and actualizado  = 1
	and periodo     >= ls_periodo1
    and periodo     <= ls_periodo2

	foreach
	 select cod_coasegur,
			prima,
			porc_comis_fac,
			porc_impuesto,
			porc_partic_reas
	   into ls_cod_rease,
			ld_prima,
			ld_porc_comision,
			ld_porc_impuesto,
			ld_porc_partic_reas
	   from emifafac
	  where no_poliza = ls_no_poliza
	    and no_endoso = ls_no_endoso 	

		if ld_porc_comision is null then
			let ld_porc_comision = 0;
		end if
		
		if ld_porc_impuesto is null then
			let ld_porc_impuesto = 0;
		end if

		let ld_comision	= ld_prima / 100 * ld_porc_comision;
		let ld_impuesto	= ld_prima / 100 * ld_porc_impuesto;

		insert into tmp_estcufa(
		cod_reasegurador,	
		ano,					
		trimestre,			
		primas,				
		comision,			
		impuestos			
		)
		values(
		ls_cod_rease,
		a_ano,
		a_trimestre,
		ld_prima,
		ld_comision,
		ld_impuesto
		);		

	end foreach

end foreach

Begin

define ld_prima_debe		dec(16,2);
define ld_prima_haber		dec(16,2);
define ld_reserva_dev_debe	dec(16,2);
define ld_reserva_dev_haber	dec(16,2);
define ld_interes_debe		dec(16,2);
define ld_interes_haber		dec(16,2);
define ld_imp_interes_debe	dec(16,2);
define ld_imp_interes_haber	dec(16,2);
define ld_comision_debe		dec(16,2);
define ld_comision_haber	dec(16,2);
define ld_impuesto_debe		dec(16,2);
define ld_impuesto_haber	dec(16,2);
define ld_siniestro_pagado	dec(16,2);
define ld_siniestro_contado	dec(16,2);
define ld_reserva_retenida	dec(16,2);
define ld_sobrecomision		dec(16,2);
define _siniestro_pag_debe  dec(16,2);
define _siniestro_pag_haber	dec(16,2);


-- Maque

-- Lectura de Tablas Relacionadas
-- Compania Coaseguradora
	Select nombre												
	  Into ls_nombre_coasegur
	  From emicoase
	 Where cod_coasegur = ls_cod_rease;
-- Ramo
    Select cod_ramo
	  Into ls_cod_ramo
	  From emipomae
	 Where no_poliza = ls_no_poliza;

	Select nombre
	  Into ls_nombre_ramo
	  From prdramo
	 Where cod_ramo = ls_cod_ramo;

-- Produccion- Endedmae
Foreach
 Select prima_bruta
   Into ld_prima_bruta
   From endedmae
  Where no_poliza = ls_no_poliza
    And no_endoso = ls_no_endoso

--Reclamos-Pagos
Foreach
 Select no_reclamo
   Into ls_no_reclamo
   From recrcmae
  Where no_poliza = ls_no_poliza 

	Foreach
	 Select monto
	   Into	ld_monto
	   From	rectrmae
	  Where no_reclamo   = ls_no_reclamo
	    AND cod_tipotran = 4
	    And	actualizado  = 1

--Reaseguro-Ajustes
  --Contratos
{	Foreach
	 Select cod_contrato,
			prima
	   Into	_cod_contrato,
			_prima
	   From emifacon 
	  Where	no_poliza   = _no_poliza
		And no_endoso   = _no_endoso}

-- Arma el Estado de Cuenta
Foreach
 Select cod_reasegurador,
		sum(primas),				
		sum(reserva_devuelta),	
		sum(int_reserva_dev),		
		sum(imp_int_res_dev),		
		sum(comision),			
		sum(impuestos),			
		sum(sobrecomision),		
		sum(siniestro_pagado),	
		sum(siniestro_contado),
		sum(reserva_retenida)	
   Into	ls_cod_rease,
        ld_prima_haber,
		ld_reserva_dev_debe,
		ld_interes_debe,
		ld_imp_interes_haber,
		ld_comision_debe,
		ld_impuesto_debe,
		ld_sobrecomision,
		ld_siniestro_pagado,
		ld_siniestro_contado,
		ld_reserva_retenida
   From tmp_estcufa
  Where ano		  = a_ano
    And	trimestre = a_trimestre

--end foreach;

	Return ls_nombre_coasegur,
	       ls_nombre_ramo,
		   ld_participacion,
		   a_trimestre,
		   a_ano,
		   ld_prima_haber,
		   ld_prima_debe,
		   ld_comision_debe,
		   ld_comision_haber,
		   ld_impuestos_debe,
		   ld_impuesto_haber,
		   _siniestro_pag_debe,
		   _siniestro_pag_haber,
	 	   v_compania_nombre
		   WITH RESUME;	
		    

end foreach;
end foreach;
end foreach;
end foreach;
end 
end procedure;