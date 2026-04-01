-- Procedimiento para Consultar Cobmoros para cierre contable
--
-- Creado Por  : 05/10/2018 - Autor: JesÃºs R. Brito
--
-- SIS v.3.0 - DEIVID, S.A.


drop procedure "informix".sp_cobmoros;
create procedure "informix".sp_cobmoros(pPeriodo char(7))
returning char(150) as nombre,
          char(20) as origen,
          char(7)  as periodo,
          char(150) as TipoProduccion,		  
          dec(16,2) as Saldo,
          dec(16,2) as SaldoNeto,
          dec(16,2) as Saldo_pxc,
		  dec(16,2) as Impuesto_pxc;

define        nombre           char(150);
define        origen      	   char(20);
define        Periodo     	   char(7);
define        TipoProduccion   char(150);		  
define        Saldo  		   dec(16,2);
define        SaldoNeto		   dec(16,2);
define        Saldo_pxc  	   dec(16,2);
define		  Impuesto_pxc     dec(16,2);
		  
		  
set isolation to dirty read;

foreach

SELECT
  prdramo.nombre,
  case  emipomae.cod_origen
	when "001" then "Local"
	when "002" then "Exterior"
  end as Origen,
  cobmoros1.periodo,
  case  emipomae.cod_tipoprod
        when "001" then "001 - Coaseguro Mayoritario"
        when "002" then "002 - Coaseguro Minoritario"
        when "004" then "004 - Reaseguro Asumido"
        when "005" then "005 - Produccion Directa"
  end as TipoProduccion,

  sum( cobmoros1.saldo) as Saldo,
  sum( cobmoros1.saldo_neto) as SaldoNeto,
  sum( cobmoros1.saldo_pxc * emipoagt.porc_partic_agt/100) as Saldo_pxc,
  sum( cobmoros1.impuesto_pxc * emipoagt.porc_partic_agt/100) as Impuesto_pxc

INTO nombre, origen, Periodo, TipoProduccion, Saldo, SaldoNeto, Saldo_pxc, Impuesto_pxc  
FROM
   prdramo,
   cliclien,
   emipomae,
   emipoagt,
   deivid_cob:cobmoros2 as cobmoros1,
   cobforpa,
   agtagent,
   cligrupo
WHERE
  (  cligrupo.cod_grupo= emipomae.cod_grupo  )
  AND  (  cliclien.cod_cliente= emipomae.cod_contratante  )
  AND  (  emipomae.cod_ramo= prdramo.cod_ramo  )
  AND  (  emipomae.no_poliza= emipoagt.no_poliza  )
  AND  (  agtagent.cod_agente= emipoagt.cod_agente  )
  AND  (  emipomae.no_poliza= cobmoros1.no_poliza  )
  AND  (  emipomae.cod_formapag= cobforpa.cod_formapag  )
  AND     cobmoros1.Saldo_pxc <> 0
  AND     cobmoros1.periodo  =  pPeriodo
 

GROUP BY
   prdramo.nombre,
   emipomae.cod_origen,
   cobmoros1.periodo,
   emipomae.cod_tipoprod
   
RETURN nombre, origen, Periodo, TipoProduccion, Saldo, SaldoNeto, Saldo_pxc, Impuesto_pxc  with resume;
end foreach   

end procedure
