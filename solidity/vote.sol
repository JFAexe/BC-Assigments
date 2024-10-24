// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.26;

contract Vote {
    string private reason;
    uint   private goal;

    uint private votes_for;
    uint private votes_against;
    uint private votes_abstained;

    enum Type { None, For, Against, Abstained }

    mapping( address => Type ) private votes;

    constructor( string memory r, uint g ) payable {
        reason = r; // 4.1 Предложение голосования.
        goal   = g; // 4.2 Количество требуемых голосов.
    }

    // 4.3 Просмотр предложения.
    function Reason( ) public view returns ( string memory ) {
        return reason;
    }

    // 4.4 Голос "воздержаться".
    function VoteAbstain( ) public canVote {
        votes[ msg.sender ] = Type.Abstained;
        votes_abstained++;
    }

    // 4.5 Голос "за".
    function VoteFor( ) public canVote {
        votes[ msg.sender ] = Type.For;
        votes_for++;
    }

    // 4.6 Голос "против".
    function VoteAgainst( ) public canVote {
        votes[ msg.sender ] = Type.Against;
        votes_against++;
    }

    // 4.7 Просмотр результата голосования.
    function Result( ) public view isFinished returns ( string memory ) {
        if ( votes_for > votes_against ) {
            return "for";
        }

        if ( votes_against > votes_for ) {
            return "against";
        }

        return "undecided";
    }

    // 4.8 Просмотр статистики голосования.
    function Stats( ) public view isFinished returns ( uint, uint, uint ) {
        return ( votes_for, votes_against, votes_abstained );
    }

    // 4.9 Просмотр выбора для определенного адреса.
    function Choice( address voter ) public view isFinished returns ( string memory ) {
        return TypeToString( votes[ voter ] );
    }

    function TypeToString( Type value ) private pure returns ( string memory ) {
        if ( value == Type.Abstained ) {
            return "Abstained";
        } else if ( value == Type.For ) {
            return "For";
        } else if ( value == Type.Against ) {
            return "Against";
        }

        return "None";
    }

    // 4.10 Проверка окончания голосования.
    function HasFinished( ) private view returns ( bool ) {
        return ( votes_for + votes_against + votes_abstained ) >= goal;
    }

    modifier canVote( ) {
        require( !HasFinished( ), "Go away, vote is concluded." );
        // 4.11 Проверка на наличие голоса.
        require( votes[ msg.sender ] == Type.None, "Go away, you've voted already." );

        _;
    }

    modifier isFinished( ) {
        require( HasFinished( ), "Go away, vote is in progress." );

        _;
    }
}
