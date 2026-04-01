-- Depuracion de la tabla de Clientes
-- Creado         : 06/04/2005 - Autor: Demetrio Hurtado Almanza 
-- Modificado Por : 11/10/2007 - Rub‚n Arn ez
drop procedure sp_sis73c;

create procedure "informix".sp_sis73c(
a_cod_errado	char(10), 
a_cod_correcto 	char(10),
a_user			char(8)
) returning integer,
            char(100);

define _error	integer;
define _cod_cliente   char(10);
define _nombre        char(30);
define _cod_errado   char(10);
define _cod_correcto char(10);
define _tiempo	     datetime year to fraction(5);
define _nom_tabla    char(30);
define _no_doc		 char(20); 
define _cnt			 integer;
define _no_documento char(20);

define _dia_cobros1  smallint;
define _dia_cobros2  smallint;
define _a_pagar      decimal(16,2);
define _tipo_mov     char(1);

let _tiempo = current;
let _nombre      = "";
let _cod_errado  = "";
let _cod_correcto = "";
let _nom_tabla   = "";
let _cnt         = 0;

CREATE TEMP TABLE tmp_hijo(
no_documento         char(20),
cod_cliente          char(10),
dia_cobros1          smallint,
dia_cobros2          smallint,
a_pagar              decimal(16,2),
tipo_mov             char(1)
) WITH NO LOG;	  
			{
			begin work;

			begin
			on exception set _error
				rollback work;
				return _error, "Error al Actualizar el Registro";
			end exception
			 }

			select count(*)
			  into _cnt
			  from tchqchmae
			 where cod_cliente = a_cod_errado;
			   		   
			if _cnt > 0 then
			let _nom_tabla = "chqchmae";

			insert into tclidepur2
					(
					cod_errado,
					cod_correcto,
					user_changed,
					date_changed,
					nom_tabla,
					pr_key_tab
					)
			select 
					a_cod_errado,
					a_cod_correcto,
					a_user,
					_tiempo,
					_nom_tabla,
					no_requis
			  from tchqchmae
			 where cod_cliente = a_cod_errado;
						
			update tchqchmae
			   set cod_cliente = a_cod_correcto
			 where cod_cliente = a_cod_errado;

			end if

			let _cnt = 0;
			select count(*)
			  into _cnt
			  from tcliclicl
			 where cod_cliente = a_cod_errado;
			   		   
			if _cnt > 0 then
			
			let _nom_tabla = "cliclicl";
			insert into tclidepur2
			        (
					cod_errado,
					cod_correcto,
					user_changed,
					date_changed,
					nom_tabla,
					pr_key_tab
					)
			select 
					a_cod_errado,
					a_cod_correcto,
					a_user,
					_tiempo,
					_nom_tabla,
					cod_tipogar
			  from  cliclicl
			 where  cod_cliente = a_cod_errado;
			
			update tcliclicl
			   set cod_cliente = a_cod_correcto
			 where cod_cliente = a_cod_errado;

			end if

			let _cnt = 0;
			select count(*)
			  into _cnt
			  from trectrmae
			 where cod_cliente = a_cod_errado;
			   		   
			if _cnt > 0 then

			let _nom_tabla = "rectrmae";
			insert into tclidepur2
			       (
				   cod_errado,
				   cod_correcto,
				   user_changed,
				   date_changed,
				   nom_tabla,
				   pr_key_tab
				   )
			select 
				   a_cod_errado,
				   a_cod_correcto,
				   a_user,
				   _tiempo,
				   _nom_tabla,
				   no_tranrec
			  from trectrmae
			 where cod_cliente = a_cod_errado;
		   	
			update trectrmae
			   set cod_cliente = a_cod_correcto	  
			 where cod_cliente = a_cod_errado;

			end if

		    let _cnt = 0;
		    select count(*)
			  into _cnt
			  from tcaspoliza
			 where cod_cliente = a_cod_errado;
			   		   
					 if _cnt > 0 then

				   	 insert into tmp_hijo
					 select no_documento, cod_cliente, dia_cobros1, dia_cobros2, a_pagar, tipo_mov
					   from tcaspoliza
					 where cod_cliente = a_cod_errado;

					 end if
							   			      
					 delete from tcaspoliza
					 where cod_cliente = a_cod_errado;

					 update tcascliente
					   set cod_cliente = a_cod_correcto
					 where cod_cliente = a_cod_errado;	   

					update tmp_hijo
					   set cod_cliente = a_cod_correcto
					 where cod_cliente = a_cod_errado;

		  			insert into tcaspoliza
					select no_documento, cod_cliente, dia_cobros1, dia_cobros2, a_pagar, tipo_mov
					from tmp_hijo;
					
			   --	drop table tmp_hijo;
								  			 
					delete from rdaclt
					where cod_cliente = a_cod_errado;
	  		 --	end
	   		 --	rollback work;
	  		 --	return 0, "Actualizacion Exitosa";
			end procedure



