-- Procedimiento que genera el reporte de los recaudos mayores a 10,000.00
-- 
-- Creado     : 17/06/2013 - Autor: Federico V. Coronado T.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob400bk;
create procedure "informix".sp_cob400bk(a_periodo char(7))
returning integer,
          varchar(50),
          char(13),
          char(50),
          date,
          varchar(10),
		  dec(16,2),
		  varchar(50),
		  varchar(50),
		  varchar(15),
		  char(10),
		  integer,
		  char(10);
		  
define _no_documento	 char(13);
define _error			 integer;
define _error_isam		 integer;
define _error_desc		 varchar(100);
define _no_poliza		 varchar(10);
define _fecha            date;
define _monto            dec(16,2);
define _tipo_mov         char(1);
define _cod_contratante  varchar(10);
define _cod_ramo         char(3);
define _nombre           varchar(50);
define _nombre_ramo      varchar(50);
define _no_recibo        varchar(10);
define v_compania_nombre varchar(50);
define _no_remesa		 varchar(10);
define _renglon          integer;
define _tipo_pago        integer;
define _descripcion_pago varchar(50);
define _tipo_cheque      smallint;
define _desc_tipo_cheque  varchar(15);

--set debug file to "sp_cob400.trc";
--trace on;

set isolation to dirty read;

begin

create temp table tmp_recaudo(
cod_contratante		char(10),
no_remesa			char(10),
renglon             integer,
monto			    dec(16,2) 	default 0,
cod_ramo			char(3)
) with no log;

LET  v_compania_nombre = sp_sis01('001'); 
let _tipo_cheque = 0;

foreach
	select no_poliza, 
	       fecha, 
	       no_recibo, 
		   monto, 
		   tipo_mov,
		   no_remesa,
		   renglon
	  into _no_poliza,
		   _fecha,
		   _no_recibo,
		   _monto,
		   _tipo_mov,
		   _no_remesa,
		   _renglon
	  from cobredet
	 where periodo     = a_periodo
	   and tipo_mov    in ("P","N")
	   and actualizado = 1
	   
 	select cod_contratante, 
	       no_documento, 
	       cod_ramo
	  into _cod_contratante,
		   _no_documento,
		   _cod_ramo
      from emipomae
     where no_poliza = _no_poliza;

	insert into tmp_recaudo(cod_contratante,no_remesa,renglon,monto,cod_ramo)
	values (_cod_contratante,_no_remesa,_renglon,_monto,_cod_ramo);
end foreach

foreach
	select cod_contratante
	  into _cod_contratante
	  from tmp_recaudo
	 group by 1
	 having sum(monto) > 10000
	 order by 1
	 
	foreach
		select no_remesa,
		       renglon,
			   cod_ramo
		  into _no_remesa,
		       _renglon,
			   _cod_ramo
		  from tmp_recaudo
		 where cod_contratante = _cod_contratante
		 order by no_remesa, renglon 
		  
		foreach
			select fecha, 
				   no_recibo, 
				   tipo_mov,
				   doc_remesa,
				   monto
			  into _fecha,
				   _no_recibo,
				   _tipo_mov,
				   _no_documento,
				   _monto
			  from cobredet
			 where no_remesa = _no_remesa
			   and renglon   = _renglon
			   
			 select nombre 
			   into _nombre_ramo
			   from prdramo 
			  where cod_ramo = _cod_ramo;
			  
			 select tipo_pago,
					tipo_cheque	 
			   into _tipo_pago,
					_tipo_cheque
			   from cobrepag 
			  where no_remesa = _no_remesa
				and renglon   = _renglon;
			  
			 select nombre
			   into _nombre
			   from cliclien 
			  where cod_cliente = _cod_contratante;
			  
			  let _descripcion_pago = " ";
			  LET _desc_tipo_cheque = "";
			  
			  if _tipo_pago = 1 then
				let _descripcion_pago = "EFECTIVO";
			  elif _tipo_pago = 2 then
				let _descripcion_pago = "CHEQUE";
				if _tipo_cheque = 1 then
					let _desc_tipo_cheque = "GERENCIA";
				elif _tipo_cheque = 2 then
					let _desc_tipo_cheque = "LOCAL";
				elif _tipo_cheque = 3 then	
					let _desc_tipo_cheque = "EXTRANJERO";
				end if	
			  elif _tipo_pago = 3 then
				let _descripcion_pago = "CLAVE";
			  elif _tipo_pago = 4 then
				let _descripcion_pago = "TARJETA DE CREDITO";
			  else
				let _descripcion_pago = "REMESA COMPROBANTE";
			  end if
			  
			 RETURN     0, 
					   _nombre,
					   _no_documento,
					   _nombre_ramo,
					   _fecha,
					   _no_recibo,
					   _monto,
					   v_compania_nombre,
					   _descripcion_pago,
					   _desc_tipo_cheque,
					   _no_remesa,
					   _renglon,
					   _cod_contratante
					   WITH RESUME; 
			   
		end foreach
	end foreach
end foreach
drop table tmp_recaudo;

end 
end procedure