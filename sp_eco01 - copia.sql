-- Genera Cheque ACH
-- Creado    : 15/04/2011 - Autor: Amado Perez
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che123('2',0)

DROP PROCEDURE sp_eco01;
CREATE PROCEDURE sp_eco01(a_fecha1 date, a_fecha2 date) 
RETURNING  char(10) as CodCorredor,	
           char(5) as IdItem,
		   char(10) as IdPoliza,
		   char(5) as NroCertificado,
		   date as FechaAlta,
		   char(5) as CodMarca,
		   char(5) as CodModelo,
		   varchar(50) as AcreedorHipotecarioLeasing,
		   varchar(50) as AcreedorHipotecario,
		   varchar(100) as NombreConductor,
		   varchar(100) as NombrePropietario,
		   dec(16,2) as SumaAsegurada,
		   char(3) as CodTipoVehiculo,
		   varchar(50) as TipoVehiculo,
		   smallint as CantidadOcupantes,
		   dec(16,2) as PrimaBruta,
		   dec(5,2) as PorcImpuesto,
		   dec(16,2) as Impuesto,
		   dec(16,2) as Descuento,
		   dec(16,2) as PrimaNeta,
		   char(3) as IdCompania,
		   char(5) as IdEndoso,
		   datetime hour to second as FechaCreacion,
		   varchar(50) as EstadoVehiculo,
		   smallint as AnoVehiculo,
		   varchar(50) as Marca,
		   varchar(50) as Modelo,
		   varchar(30) as SerialMotor,
		   varchar(30) as SerialCarroceria,
		   varchar(50) as Color,
		   char(10) as Placa,
		   varchar(50) as CodPlan,
		   varchar(50) as RevPlan,
		   dec(16,2) as PrimaBrutaConDecRec,
		   dec(16,2) as Recargo,
		   dec(16,2) as PrimaSinRecaDcto;		   
  
DEFINE _no_poliza           char(10);
DEFINE _cod_agente          char(5);
DEFINE _no_endoso           char(5);
DEFINE _no_unidad           char(5);
DEFINE _cod_marca           char(5);
DEFINE _cod_modelo          char(5);  
DEFINE _marca               varchar(50);
DEFINE _modelo              varchar(50);
DEFINE _placa               char(10); 
DEFINE _no_chasis           varchar(30);
DEFINE _no_motor            varchar(30);
DEFINE _ano_auto            smallint;
DEFINE _cod_tipoveh         char(3);
DEFINE _cod_color           char(3);
DEFINE _suma_asegurada      dec(16,2);
DEFINE _tipo_veh            varchar(50);
DEFINE _capacidad           smallint;
DEFINE _factor_impuesto     dec(5,2);
DEFINE _color               varchar(50);
DEFINE _recargo             dec(16,2);
DEFINE _prima_neta          dec(16,2);
DEFINE _impuesto            dec(5,2);
DEFINE _descuento           dec(16,2);
DEFINE _prima_bruta         dec(16,2);

SET ISOLATION TO DIRTY READ;
--  set debug file to "sp_che117.trc";	
--  trace on;


FOREACH
select a.no_poliza,
       a.no_endoso,
       u.no_unidad,
	   u.suma_asegurada,
	   u.prima_neta,
	   u.impuesto,
	   u.descuento,
	   u.prima_bruta,
	   u.recargo,
	   em.cod_marca,
       em.cod_modelo,
       mr.nombre,
       md.nombre,
       em.placa,
	   em.capacidad,
	   em.no_chasis,
	   em.no_motor,
	   em.ano_auto,
	   ea.cod_tipoveh,
	   em.cod_color,
	   pol.cod_agente
  into _no_poliza,
	   _no_endoso,
       _no_unidad,
	   _suma_asegurada,
	   _prima_neta,
	   _impuesto,
	   _descuento,
	   _prima_bruta,
	   _recargo,
 	   _cod_marca,
       _cod_modelo,
       _marca,
       _modelo,
       _placa,
	   _capacidad,
	   _no_chasis,
	   _no_motor,
	   _ano_auto,
	   _cod_tipoveh,
	   _cod_color,
	   _cod_agente
  from endedmae a 
 inner join emipomae emi on (emi.no_poliza = a.no_poliza and a.actualizado = 1 and a.fecha_emision >= a_fecha1 and a.fecha_emision <= a_fecha2)
 inner join emipoliza pol on pol.no_poliza = a.no_poliza and pol.cod_agente in ('02111','02569')
 inner join endeduni u on (a.no_poliza = u.no_poliza and a.no_endoso = u.no_endoso)
 inner join endmoaut ea on (ea.no_poliza = a.no_poliza and a.no_endoso = ea.no_endoso and ea.no_unidad = u.no_unidad)
 inner join emivehic em on (ea.no_motor = em.no_motor)
 inner join emimarca mr on (em.cod_marca = mr.cod_marca)
 inner join emimodel md on (em.cod_marca = md.cod_marca and em.cod_modelo = md.cod_modelo)
  left join  endmoase cli on (cli.no_poliza = a.no_poliza and cli.no_endoso = a.no_endoso)
 
	
	select nombre 
	  into _tipo_veh
	  from emitiveh
	 where cod_tipoveh = _cod_tipoveh;
	 
	select sum(a.factor_impuesto)
	  into _factor_impuesto
	  from prdimpue a, endedimp b
	 where a.cod_impuesto = b.cod_impuesto
	   and b.no_poliza = _no_poliza
	   and b.no_endoso = _no_endoso;
	   
	select nombre
	  into _color
	  from emicolor
	 where cod_color = _cod_color;


	RETURN _cod_agente,
	       _no_unidad,
		   _no_poliza,
		   null,
		   null,
 	       _cod_marca,
           _cod_modelo,
		   null,
		   null,
		   null,
		   null,
		   _suma_asegurada,
		   _cod_tipoveh,
		   _tipo_veh,
		   _capacidad,
		   _prima_neta,
		   _factor_impuesto,
		   _impuesto,
		   _descuento,
		   _prima_bruta,
		   '001',
		   _no_endoso,
		   current,
		   null,
		   _ano_auto,
           _marca,
           _modelo,
	       _no_motor,
	       _no_chasis,
		   _color,
           _placa,
		   null,
		   null,
		   null,
           _recargo,
           null		   
		   WITH RESUME;		      
END FOREACH;
END PROCEDURE	  