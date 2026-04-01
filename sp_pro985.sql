-- Procedure que valida excepciones al imprimir desde el pool de impresion.
-- Creado    : 02/12/2009 - Autor: Henry Giron

-- SIS v.2.0 - DEIVID, S.A.
Drop procedure sp_pro985;

Create procedure sp_pro985(a_no_poliza char(10),a_tipo char(1))
RETURNING smallint;
BEGIN
	-- 0 Si realizar
	-- 1 No realizar

	define _cantidad	 smallint;
	let _cantidad = 0;

	set isolation to dirty read;
	
	if a_tipo = "O" then

		select count(*)
		  into _cantidad
		  from emipomae p, emitipro t
		 where p.cod_tipoprod = t.cod_tipoprod
		   and p.no_poliza = a_no_poliza
		   and t.tipo_produccion = 3   ;	 -- Excluir Original de coaseguro minoritario. Solicitud: Sra.Vielka Realizado: 2/12/2009

		if _cantidad <> 0 then
			let _cantidad = 1;
		else
			let _cantidad = 0;
		end if

	end if

	if _cantidad is null then
		let _cantidad = 0;
	end if

	if _cantidad = 0 then
		return 0;
	else
		return 1;
	end if
end
end procedure  