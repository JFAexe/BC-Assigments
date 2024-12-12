// SPDX-License-Identifier: WTFPL
pragma solidity >=0.8.26;

contract Crowdfund {
    address private creator;
    uint256 private goal;
    uint256 private deadline;
    uint256 private total_funds;

    mapping( address => uint256 ) private contributions;

    address[] private contributors;

    event ContributionMade( address contributor, uint256 amount );
    event FundsRefunded( address contributor, uint256 amount );
    event CampaignSuccessful( address creator, uint256 total );

    constructor( uint256 _goal, uint256 duration ) {
        creator     = msg.sender;
        goal        = _goal;
        deadline    = block.timestamp + duration;
        total_funds = 0;
    }

    function Contribute( ) public payable campaignOngoing {
        require( msg.value > 0, "Contribution must be greater than zero" );

        if ( contributions[ msg.sender ] == 0) {
            contributors.push( msg.sender );
        }

        contributions[ msg.sender ] += msg.value;
        total_funds += msg.value;

        emit ContributionMade( msg.sender, msg.value );
    }

    function Withdraw( ) public onlyCreator campaignEnded {
        require( IsGoalReached( ), "Can't withdraw funds from failed campaign" );

        ( bool success, ) = payable( creator ).call{ value: total_funds }( "" );

        require( success, "Transfer error" );

        emit CampaignSuccessful( creator, total_funds );
    }

    function Refund( ) public campaignEnded goalNotAchieved {
        uint256 contribution = contributions[ msg.sender ];

        require( contribution > 0, "No contribution to refund" );

        contributions[ msg.sender ] = 0;

        total_funds -= contribution;

        ( bool success, ) = payable( msg.sender ).call{ value: contribution }( "" );

        require( success, "Refund error" );

        emit FundsRefunded( msg.sender, contribution );
    }

    function GetCampaignCreator( ) public view returns ( address ) {
        return creator;
    }

    function GetCampaignGoal( ) public view returns ( uint256 ) {
        return goal;
    }

    function GetCampaignDeadline( ) public view returns ( uint256 ) {
        return deadline;
    }

    function GetTotalFunds( ) public view returns ( uint256 ) {
        return total_funds;
    }

    function IsCampaignOngoing( ) public view returns ( bool ) {
        return block.timestamp < deadline;
    }

    function IsGoalReached( ) public view returns ( bool ) {
        return total_funds >= goal;
    }

    function GetContributors( ) public view returns ( address[] memory ) {
        return contributors;
    }

    function GetContributionAmount( address contributor ) public view returns ( uint256 ) {
        return contributions[ contributor ];
    }

    modifier onlyCreator( ) {
        require( msg.sender == creator, "Only the creator can call this" );

        _;
    }

    modifier campaignOngoing( ) {
        require( IsCampaignOngoing( ), "The campaign has ended" );

        _;
    }

    modifier campaignEnded( ) {
        require( !IsCampaignOngoing( ), "The campaign is still ongoing" );

        _;
    }

    modifier goalAchieved( ) {
        require( IsGoalReached( ), "The goal was not reached" );

        _;
    }

    modifier goalNotAchieved( ) {
        require( !IsGoalReached( ), "The goal was reached" );

        _;
    }
}
