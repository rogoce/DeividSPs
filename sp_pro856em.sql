-- pool impresion de renovacion automatica
-- Creado		: 18/05/2009	- Autor: Henry Giron.
-- Modifciado	: 07/02/2012	- Autor: Roman Gordon	**Se Agrego al acreedor para aplicarlo al ordenamiento del datawindow
-- Modifciado	: 04/12/2012	- Autor: Roman Gordon	**Se Agrego el campo de leasing 

drop procedure sp_pro856em;
create procedure "informix".sp_pro856em(a_sucursal char(350), a_estatus smallint,a_desde date,a_hasta date)
	returning 	varchar(255) as filtro;

define v_filtros       	    varchar(255);
define _n_cliente       	varchar(100);
define _n_corredor      	varchar(50);
define _nom_acreedor		varchar(50);
define _no_documento		char(20);
define _no_poliza	    	char(10);
define _no_factura			char(10);
define _no_poliza2      	char(10);	 
define _cod_contratante 	char(10);	 
define _user_added   		char(8);
define _cod_agente  		char(5);
define _cod_acreedor		char(5);
define _fil_suc				char(3);
define _cod_depto			char(3);
define _sucursal        	char(3);
define _cod_ramo        	char(3);
define _suc_prom        	char(3);
define _cod_sucursal  		char(3);
define _cod_no_renov   		char(3);
define _tipo				char(1);
define _saldo				dec(16,2);
define _incurrido			dec(16,2);
define _pagos   			dec(16,2);
define _porc_depreciacion	dec(5,2);
define _renovar   			smallint;
define _estatus         	smallint;
define _no_renovar			smallint;
define _cant_reclamos		smallint;
define _status_imp			smallint;
define _leasing				smallint;
define _can_uni				smallint;
define _cnt_acre			smallint;
define _cnt_uni				integer;
define _saldo_porc      	integer;
define _fecha_selec			date;
define _vigencia_inic		date;
define _vigencia_final		date;
define _cod_vendedor       	char(3);
define _cod_leasing         char(10);
define _no_unidad			char(5);
define _n_ramo      	    varchar(50);
define _cedula     	        varchar(50);
define _email       	    varchar(100);
define _cnt_emireimp        smallint;
define _cnt_sus             smallint;

drop table if exists tmp_codigos;	
drop table if exists temp_acreedor;	
create temp table temp_acreedor (
                no_documento  char(20),
				n_ramo        varchar(50), 
				no_factura    char(10),
				n_cliente     varchar(100),
				cedula        varchar(50),
				n_corredor     varchar(50),
				vigencia_inic  date,
				vigencia_final  date,
				nom_acreedor  varchar(50),
				cod_acreedor  char(20),
				email        varchar(100),
				fecha_selec   date,
primary key (no_factura)) with no log;
--) with no log;

set isolation to dirty read;

--set debug file to "sp_pro856.trc";
--trace on;

let _leasing = 0;
	
if a_sucursal in ('*','*;') then	

	if a_sucursal = '*;' then
		let a_sucursal = '001';
	else
		let a_sucursal = '';--'006';
	end if
	
	foreach
		select codigo_agencia 
		  into _cod_sucursal 
		  from insagen   
		 where sucursal_promotoria <> '001' 
		
		if a_sucursal = '' or a_sucursal is null then 
			let a_sucursal = trim(a_sucursal) || trim(_cod_sucursal); 
		else 
			let a_sucursal = trim(a_sucursal) || ',' || trim(_cod_sucursal); 
		end if 
	end foreach 
	
	let a_sucursal = trim(a_sucursal) || ';';  
	let _tipo = sp_sis04(a_sucursal); -- Separa los valores del String 
else
	let _tipo = sp_sis04(a_sucursal); -- Separa los valores del String 
end if
{
    drop table if exists tmp_poliza15;
    select no_documento
  	  into _no_documento
  	  from emipomae
     where fecha_suscripcion between a_desde and a_hasta
	 into temp tmp_poliza15;
}
drop table if exists tmp_emirepo;
select *
   from emirepo  
     where estatus   in ( a_estatus,9)
  into temp tmp_emirepo;

foreach
	select no_poliza,   
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
           cod_agente,
           estatus,
           cod_sucursal,
		   status_imp
	  into _no_poliza,
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
           _estatus,
           _cod_sucursal,
		   _status_imp  		   
      from tmp_emirepo  
     where estatus   in ( a_estatus,9)
	   --and fecha_selec >= a_desde   and fecha_selec <= a_hasta
	   --and (cod_acreedor <>"" or leasing = 1) 
	   and status_imp in (0,1) and no_documento not like '08%'
	 order by cod_sucursal

	let _no_poliza2 = sp_sis21(_no_documento);
	
	select count(*)
  	  into _cnt_sus
  	  from emipomae
     where no_poliza = _no_poliza2
       and fecha_suscripcion >= a_desde and fecha_suscripcion <= a_hasta ; 
	   
	   if _cnt_sus is null then
	   let _cnt_sus = 0;
	   end if
	   
	   if _cnt_sus = 0 then
	     continue foreach;
	   end if	


	select cod_contratante,
           vigencia_inic,
		   vigencia_final,
		   sucursal_origen,
		   cod_ramo,
		   leasing,
		   no_factura,
		   fecha_suscripcion
  	  into _cod_contratante,
	       _vigencia_inic,
		   _vigencia_final,
		   _sucursal,
		   _cod_ramo,
		   _leasing,
		   _no_factura,
		   _fecha_selec
  	  from emipomae
     where no_poliza = _no_poliza2;
	 
       { if _fecha_selec >= a_desde and _fecha_selec <= a_hasta  then  --15112022
		else
			continue foreach;
		end if}	 
	 

	
	let _cod_acreedor = '';
	let _nom_acreedor = ''; 
	let _email = ''; 
	
	if _sucursal = '010' then
		let _sucursal = '001';
	end if
		
	foreach
		select cod_acreedor
		  into _cod_acreedor
		  from emipoacr
		 where no_poliza = _no_poliza2

		select nombre,email
		  into _nom_acreedor,_email
		  from emiacre
		 where cod_acreedor = _cod_acreedor;

		exit foreach;
	end foreach
	if _email is null or _email = '' then 
		continue foreach;
	end if			
	
	if _cod_acreedor is null or _cod_acreedor = '' then
	    if _leasing = 1 then
			foreach
				select no_unidad
				  into _no_unidad
				  from emipouni
				 where no_poliza = _no_poliza2
			 exit foreach;
			end foreach
			select cod_asegurado
			  into _cod_leasing
			  from emipouni
			 where no_poliza = _no_poliza2
               and no_unidad = _no_unidad;
		   select nombre,e_mail
			 into _nom_acreedor,_email
			 from cliclien
			where cod_cliente = _cod_leasing;
		else	   
			let _cod_acreedor = '';
		end if
	end if
	
	select sucursal_promotoria
	  into _suc_prom
	  from insagen
	 where codigo_agencia  = _sucursal
	   and codigo_compania = '001';
	
	if _cod_ramo <> "008" then  --fianzas si se imprime en casa matriza siempre.
		if _suc_prom not in (select codigo from tmp_codigos) then 
			continue foreach;
		end if
	end if

	select nombre, cedula
	  into _n_cliente, _cedula
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select nombre,
	       cod_vendedor
 	  into _n_corredor,
		   _cod_vendedor
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	 select count(*)
	   into _cnt_uni 
	   from emipouni
	  where no_poliza = _no_poliza2;  ---_no_poliza;
	  
	  if _cnt_uni > 2 then 
		let _can_uni = 1; 
	  else
		let _can_uni = 0;
	  end if 
	  
	select nombre
	  into _n_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
	 
	  --	if _cod_acreedor = '' or _leasing <> 1 then 
		--	continue foreach;
		--end if		

	  let _cnt_emireimp = 0;
	 select count(*)
	   into _cnt_emireimp 
	   from emireimp
	  where no_poliza = _no_poliza2;   --_no_poliza;	
	  
		if _cnt_emireimp > 1 then  --SD#7004 JEPEREZ 
			continue foreach;
		end if	  		
		
	
	begin
	on exception in(-239,-268)
	end exception	
		insert into temp_acreedor
			values( _no_documento,   
			_n_ramo,
			_no_factura,   
			_n_cliente,
			_cedula,
			_n_corredor,
			_vigencia_inic,   
			_vigencia_final,
			_nom_acreedor,
			_cod_acreedor,
			_email,
			_fecha_selec
			);	
   end			


end foreach
drop table if exists tmp_codigos;	

return 'Exito';

end procedure	