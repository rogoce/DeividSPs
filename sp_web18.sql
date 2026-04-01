-- Procedure para cargar en la pagina web las polizas que no tienen pagos por corredor

-- Creado: 20/09/2012 - Autor: Federico Coronado

drop procedure sp_web18;

create procedure "informix".sp_web18(a_cod_corredor char(10))
returning char(20),
		  char(50),
		  char(10),
		  date,
		  date,
		  char(3),
		  char(100),
		  char(10),
		  varchar(20),
		  char(50),
		  varchar(8),
		  char(1),
		  varchar(5),
		  varchar(50),
		  varchar(3),
		  date,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  integer,
		  varchar(100);

define _no_poliza			char(10);
define _no_documento		char(20);
define _cod_contratante     char(10);
define _cod_pagador         char(10);
define _nombre_contratante  char(50);
define _nombre_pagador      char(50);
define _nombre_ramo         char(50);
define _cod_ramo            char(3);
define _vigencia_inic       date;
define _vigencia_final      date;
define _cantidad			smallint;
define _estatus_poliza      smallint;
define _estado              varchar(20);
define _user_added          varchar(8);
define _nueva_renov         char(1);
define _cod_grupo           varchar(5);
define _nombre_grupo        varchar(50);
define _cod_sucursal        varchar(3);
define _fecha_suspension    date;
define _saldo			    dec(16,2);
define _saldo_poliza        dec(16,2);
define _por_vencer		    dec(16,2);
define _exigible			dec(16,2);
define _corriente			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2);	
define _leasing				integer;
define _cnt_agt             smallint;
define _cnt_uni             smallint;
define _nombre_asegurado	varchar(100);
define _cod_asegurado_uni	varchar(10);

--set debug file to "sp_web18.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

         let _no_documento = '';
		 let _no_poliza = '';
		 let _cantidad = 0;
	foreach
		  select no_documento 
		  into  _no_documento
		  from	emipoagt inner join emipomae on emipomae.no_poliza = emipoagt.no_poliza
		  where cod_agente = a_cod_corredor
		  and actualizado = 1
		  and no_documento is not null
		  and cod_formapag <> '084'
		  group by no_documento
		  order by no_documento
		  
		  let _no_poliza = sp_sis21(_no_documento);
		  
		  select count(*)
		    into _cnt_agt
		    from emipoagt
		   where no_poliza 	= _no_poliza
		     and cod_agente = a_cod_corredor;
		  
		  if _cnt_agt = 0 then
				CONTINUE FOREACH;
		  end if
		  
		  select cod_ramo
		    into _cod_ramo
			from emipomae
		   where no_poliza = _no_poliza;
		   
		 if _cod_ramo = '020' then
			let _saldo_poliza =  sp_cob174(_no_documento);
			
			if _saldo_poliza > 0 then
				let _cantidad = 0;
			else
				let _cantidad = 1;
			end if
		 else
			select count(*)
			  into _cantidad
			  from cobredet
			  where no_poliza = _no_poliza;
		 end if
		 
		if _cantidad > 0 then
			CONTINUE FOREACH;
		else
			select cod_contratante,
				   cod_ramo,
				   vigencia_inic,
				   vigencia_final,
				   estatus_poliza,
				   cod_pagador,
				   user_added,
				   cod_grupo,
				   nueva_renov,
				   cod_sucursal,
				   leasing
			into _cod_contratante,
				 _cod_ramo,
				 _vigencia_inic,
				 _vigencia_final,
				 _estatus_poliza,
				 _cod_pagador,
				 _user_added,
				 _cod_grupo,
				 _nueva_renov,
				 _cod_sucursal,
				 _leasing
			from emipomae
			where no_poliza = _no_poliza; 
			
			if _estatus_poliza in(2,4) then
				CONTINUE FOREACH;
			end if
			
			select count(*)
			  into _cnt_uni
			  from deivid:emipouni
			 where no_poliza = _no_poliza;
			
			if _cnt_uni > 1 then
				let _nombre_asegurado = "";
			else 
				select cod_asegurado
				 into _cod_asegurado_uni
				 from deivid:emipouni
				where no_poliza = _no_poliza;
				
				select nombre
				  into _nombre_asegurado
				  from deivid:cliclien
				 where cod_cliente = _cod_asegurado_uni;
			end if

			select nombre
			into _nombre_contratante
			from cliclien
			where cod_cliente = _cod_contratante;
			
			select nombre
			into _nombre_pagador
			from cliclien
			where cod_cliente = _cod_pagador;
			
			select nombre 
			into _nombre_grupo
			from cligrupo 
			where cod_grupo = _cod_grupo;
			
			select fecha_suspension,
				   saldo,
				   por_vencer,
				   exigible,
				   corriente,
				   monto_30,
				   monto_60,
				   monto_90			
			into _fecha_suspension,
				 _saldo,
				 _por_vencer,
				 _exigible,
				 _corriente,
				 _monto_30,
				 _monto_60,
				 _monto_90		
			from emipoliza 
			where no_documento = _no_documento;
			
			select nombre
			into _nombre_ramo
			from prdramo
			where cod_ramo = _cod_ramo;
		    end if
			
			if _estatus_poliza = 1 then
				let _estado = "VIGENTE";
			elif _estatus_poliza = 2 then
				let _estado = "CANCELADA";
			elif _estatus_poliza = 3 then
				let _estado = "VENCIDA";
			elif _estatus_poliza = 4 then
				let _estado = "ANULADA";				
			end if
		  
	return _no_documento,
		   _nombre_contratante,
		   _no_poliza, 
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _nombre_ramo,
		   _cod_contratante,
		   _estado,
		   _nombre_pagador,
		   _user_added,
		   _nueva_renov,
		   _cod_grupo,
		   _nombre_grupo,
		   _cod_sucursal,
		   _fecha_suspension,
		   _saldo,
		   _por_vencer,
		   _exigible,
		   _corriente,
		   _monto_30,
		   _monto_60,
		   _monto_90,
		   _leasing,
		   _nombre_asegurado
		   with resume;
		   
	end foreach
end procedure