-- Consulta de Remesas con Movimientos de Cuentas Sac auxiliar A0035 y cuenta 2660101
-- Creado    : 28/10/2021 - Autor: Amado Perez
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_che242('121020402','COB12091','18/12/2009')

DROP PROCEDURE sp_che242;
CREATE PROCEDURE sp_che242() 
RETURNING	char(10) as remesa,	
            integer as renglon,	
			char(20) as poliza, 		 
			varchar(100) as nombre,			
			DEC(16,2) as monto,		
			DEC(16,2) as prima_neta,		
			DEC(16,2) as desc_ducruet,		
			DEC(5,2) as comision_aa,
			date as fecha;
			--char(15) as comprobante,
			--dec(16,2) as debito,
			--dec(16,2) as credito;		

DEFINE _no_remesa			char(10);
DEFINE _renglon             integer;
DEFINE _debito           	DEC(16,2);
DEFINE _credito           	DEC(16,2);
DEFINE _doc_remesa          char(30);
DEFINE _no_poliza           char(10);
DEFINE _monto           	DEC(16,2);
DEFINE _prima_neta          DEC(16,2);
DEFINE _cod_contratante     char(10);
DEFINE _porc_comis_agt      DEC(5,2);
DEFINE _porc_partic_agt     DEC(5,2);
DEFINE _descuenta_dc        DEC(16,2);
DEFINE _nombre           	varchar(100);
DEFINE _res_fechatrx        date;
DEFINE _res_comprobante     char(15);
DEFINE _cod_agente          char(5);


SET ISOLATION TO DIRTY READ;

--  set debug file to "sp_sac152.trc";	 
--  trace on;


FOREACH
	select n.no_remesa,
	       n.renglon,
		   n.debito,
		   n.credito,
		   m.res_fechatrx,
		   m.res_comprobante
	  into _no_remesa,
           _renglon,
           _debito,
           _credito,
           _res_fechatrx,
		   _res_comprobante
	  from cglresumen1 d, cglresumen m, sac999:cobasien n
	 where m.res_noregistro = d.res1_noregistro
           and m.res_notrx = n.sac_notrx
           and d.res1_cuenta = n.cuenta
	   and d.res1_cuenta = '2660101'
	   and d.res1_auxiliar = 'A0035'
	   and m.res_fechatrx >= '01/01/2020'
	   and m.res_fechatrx <= '31/10/2021'
           and res_origen = 'COB'
	 order by res_fechatrx, res_comprobante, res_tipcomp, res_origen, n.renglon
	 
	select doc_remesa,
	       no_poliza,
		   monto,
		   prima_neta
	  into _doc_remesa,
           _no_poliza,
		   _monto,
		   _prima_neta
      from cobredet
     where no_remesa =_no_remesa	  
	   and renglon = _renglon;
	   
    select cod_agente,
	       porc_comis_agt, 
	       porc_partic_agt 
      into _cod_agente,
	       _porc_comis_agt,
           _porc_partic_agt
      from cobreagt
     where no_remesa = _no_remesa
       and renglon = _renglon;	 
	   
	if _cod_agente <> "00035" THEN
		CONTINUE foreach;
	end if		
	   
	select cod_contratante
      into _cod_contratante
      from emipomae
     where no_poliza = _no_poliza;
 
		   
    let _descuenta_dc = _debito - _credito;
	
	select nombre
	  into _nombre
	  from cliclien
	 where cod_cliente = _cod_contratante;
	 
	return _no_remesa,
           _renglon,
		   _doc_remesa,
		   _nombre,
		   _monto,
		   _prima_neta,
		   _descuenta_dc,
		   _porc_comis_agt,
		   _res_fechatrx with resume; --,
         --  _res_comprobante,
		 --  _debito, 
		 --  _credito with resume;
		   
END FOREACH




END PROCEDURE					 