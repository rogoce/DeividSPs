-- pool renovacion automatica

-- Creado    : 15/05/2009 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro324;
CREATE PROCEDURE sp_pro324()
returning varchar(50),	 --_n_corredor,
		  char(10),		 --_no_poliza,
		  char(8),		 --_user_added,   
		  char(3),       --_cod_no_renov,   
		  char(20),		 --_no_documento,   
		  smallint,		 --_renovar,   
		  smallint,		 --_no_renovar,   
		  date,			 --_fecha_selec,   
		  date,			 --_vigencia_inic,   
		  date,			 --_vigencia_final,   
		  dec(16,2),	 --_saldo,   
		  smallint,		 --_cant_reclamos,   
		  char(10),		 --_no_factura,   
		  decimal(16,2), --_incurrido,   
		  decimal(16,2), --_pagos,   
		  decimal(5,2),	 --_porc_depreciacion,
		  char(5),	   	 --_cod_agente,
		  varchar(100),  --_n_cliente,
		  decimal(16,2), --_prima_bruta,
		  decimal(16,2), --_diezporc,
		  char(10),		 --_cod_contratante  
		  integer,
		  char(10),
		  smallint,
		  varchar(50);

define _no_poliza	    char(10);	 
define _cod_contratante char(10);	 
define _prima_bruta	    dec(16,2);	 
define _user_added   	char(8);
define _cod_no_renov   	char(3);
define _no_documento	char(20);
define _renovar   		smallint;
define _no_renovar		smallint;
define _fecha_selec		date;
define _vigencia_inic	date;
define _vigencia_final	date;
define _saldo			dec(16,2);
define _cant_reclamos	smallint;
define _no_factura		char(10);
define _incurrido		dec(16,2);
define _pagos   		dec(16,2);
define _porc_depreciacion  dec(5,2);
define _cod_agente  	char(5);
define _saldo_porc,_saldo_elect      integer;
define _n_cliente       varchar(100);
define _n_corredor      varchar(50);
define _diezporc      	dec(16,2);
define _fecha_hoy       date;
define _dias            integer;
define _cod_formapag    char(3);
define _tipo_forma      smallint;
define _usuario_cobros  char(8);
define _cantidad        integer;
define _inc_total       dec(16,2);
define _saldos          dec(16,2);
define _cant_mov        smallint;
define _cod_subramo, _cod_ramo     char(3);
define _subramo         varchar(50);
DEFINE _no_unidad		CHAR(5);
DEFINE _cod_tipoveh		CHAR(3);
DEFINE _uso_auto		CHAR(1);
DEFINE _no_motor		CHAR(30);
define _nuevo           smallint;
define _cnt_prod_exc    integer;
let _fecha_hoy = current;


SET ISOLATION TO DIRTY READ;

select usuario_cobros
  into _usuario_cobros
  from emirepar;

let _saldo_elect = 0;
let _saldo_porc  = 0;  
foreach
	SELECT no_poliza,   
	       user_added,   
	       cod_no_renov,   
	       no_documento,   
		   renovar,   
		   no_renovar,   
		   fecha_selec,   
		   vigencia_inic,   
		   vigencia_final,   
		   saldo,   
		   cant_reclamos,   
		   no_factura,   
		   incurrido,   
		   pagos,   
		   porc_depreciacion,   
		   cod_agente  
	  INTO _no_poliza,
		   _user_added,   
		   _cod_no_renov,   
		   _no_documento,   
		   _renovar,   
		   _no_renovar,   
		   _fecha_selec,   
		   _vigencia_inic,   
		   _vigencia_final,   
		   _saldo,   
		   _cant_reclamos,   
		   _no_factura,   
		   _incurrido,   
		   _pagos,   
		   _porc_depreciacion,
		   _cod_agente  
	  FROM emirepo  
	 WHERE user_added IN('AUTOMATI',_usuario_cobros)
	   AND estatus    in(1,2)

    SELECT cod_contratante,
           prima_bruta,
		   cod_formapag,
		   cod_ramo,
		   cod_subramo
	  INTO _cod_contratante,
	       _prima_bruta,
		   _cod_formapag,
		   _cod_ramo,
		   _cod_subramo
	  FROM emipomae
     WHERE no_poliza = _no_poliza;

	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;
	 
	select saldo_elect,
	       saldo_porc
	  into _saldo_elect,
	       _saldo_porc
	  from emirepar;
		  
	if _tipo_forma = 2 or _tipo_forma = 3 or _tipo_forma = 4 then	--2=visa,3=desc salario,4=ach
		let _saldo_porc = _saldo_elect;
	end if

  if _saldo_porc is null then
	let _saldo_porc = 10;
  end if

  let _diezporc = 0;
  let _diezporc = _prima_bruta * (_saldo_porc/100);

  select nombre
    into _n_cliente
    from cliclien
   where cod_cliente = _cod_contratante;

  select nombre
    into _n_corredor
    from agtagent
   where cod_agente = _cod_agente;

  let _dias = _fecha_hoy - _fecha_selec;
  
  call sp_pro82mm(_no_documento) returning _cant_mov;
  
  select nombre
    into _subramo
	from prdsubra
   where cod_ramo = _cod_ramo
     and cod_subramo = _cod_subramo;
	 
 if _cod_ramo in ('023','020','002') then	--preguntar '002',SD#5155 JEPËREZ	
	 {
	 TIPO VEHICULO	003 TAXIS
	 USO	COMERCIAL – C
	 CONDICION	NUEVO	USADO
	 % DEPRECIACION	20	15			 
	 }	
	 
	-- Excluir estos productos del proceso de renovación autmática 08-07-2024 solicitado por Bonizuth
	--AUTO COMPLETA (UNPAC) EXTRA-PLUS - 04563
	--AUTO COMPLETA - BANISI / UNITY - 07755
	--PETROAUTOS / BANISI (CAMIONETA Y PICK UP) - 03812
	--PETROAUTOS / BANISI (SEDANES) - 03811
	--PETROAUTOS / SCOTIA BANK (CAMIONETA Y PICK UP) - 02283
	--AUTORC - SICACHI / CANATRACA B/.112.00 - 08268
	--AUTORC - SICACHI / CANATRACA B/.236.00 - 08307
	--AUTORC - SICACHI / CANATRACA B/.134.00 - 08305
	--AUTORC - SICACHI / CANATRACA B/.169.00 – 08306
	
{	let _cnt_prod_exc = 0;
	
	select count(*)
	  into _cnt_prod_exc
	  from emipouni
	 where no_poliza = _no_poliza
	   and cod_producto in ('04563','07755','03812','03811','02283','08268','08307','08305','08306','03810','07754','07213','02282','08267');
	 
	if _cnt_prod_exc is null then
		let _cnt_prod_exc = 0;
    end if	
	
    if _cnt_prod_exc > 0 then
		continue foreach;
	end if
	
	if _saldo > _diezporc then
		continue foreach;
	end if
}	 
	foreach
	SELECT no_motor,
	       cod_tipoveh,
		   uso_auto,
		   no_unidad
	  INTO _no_motor,
	       _cod_tipoveh,
		   _uso_auto,
		   _no_unidad
	  FROM emiauto
	 WHERE no_poliza = _no_poliza
	 
	 select nuevo
	  into _nuevo
	  from emivehic
	 where no_motor = _no_motor;	 
	
	 if _cod_tipoveh = '003' then
		if _uso_auto = 'C' then
			if _nuevo = 1 then
				let _porc_depreciacion	= 20;	
			else
				let _porc_depreciacion	= 15;							
			end if	

		end if
	 end if 
	 
	 if _porc_depreciacion > 0 then 
	    exit foreach;
	 end if
	 
   end foreach	 
   
  end if
  --let _porc_depreciacion	= 20;	

   return _n_corredor,
   		  _no_poliza,
   		  _user_added,   
   		  _cod_no_renov,   
		  _no_documento,   
		  _renovar,   
		  _no_renovar,   
		  _fecha_selec,   
		  _vigencia_inic,   
		  _vigencia_final,   
		  _saldo,   
		  _cant_reclamos,   
		  _no_factura,   
		  _incurrido,   
		  _pagos,   
		  _porc_depreciacion,
		  _cod_agente,
		  _n_cliente,
		  _prima_bruta,
		  _diezporc,
		  _cod_contratante,
		  _dias,
		  null,
		  _cant_mov,
          _subramo		  
		  with resume;
end foreach
END PROCEDURE
